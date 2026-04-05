import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/financing/infrastructure/datasource/remote/loan_firestore.dart';
import '../../features/financing/domain/entities/loan.dart';

/// Processes the sync_queue table, retrying failed remote writes.
/// Uses Firebase WriteBatch for atomic, faster bulk uploads and embeds sub-items.
class SyncService {
  final Database db;
  final LoanRemoteDataSource loanRemote;
  final FirebaseFirestore firestore;

  SyncService(this.db, this.loanRemote, this.firestore);

  Future<void> processQueue() async {
    final now = DateTime.now();
    final items = await db.query(
      'sync_queue',
      where: 'retryCount < ?',
      whereArgs: [10],
    );
    
    if (items.isEmpty) return;

    final batch = firestore.batch();
    final processedIds = <String>[];
    final failedIds = <String, int>{};

    for (final item in items) {
      final retryCount = item['retryCount'] as int;
      final lastAttemptedAt = item['lastAttemptedAt'] as String?;

      if (lastAttemptedAt != null) {
        final lastAttempt = DateTime.parse(lastAttemptedAt);
        final backoffSeconds = pow(2, retryCount).toInt() * 60;
        if (now.difference(lastAttempt).inSeconds < backoffSeconds) {
          continue;
        }
      }

      try {
        final type = item['type'] as String;
        final payload = jsonDecode(item['payload'] as String) as Map<String, dynamic>;

        await _addToBatch(type, payload, batch);
        processedIds.add(item['id'] as String);
        await _markSynced(type, payload);
      } catch (_) {
        failedIds[item['id'] as String] = retryCount + 1;
      }
    }

    try {
      if (processedIds.isNotEmpty) {
        await batch.commit();
        
        // Cleanup synced items
        for (final id in processedIds) {
          await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
        }
      }
    } catch (_) {
      // If batch fails, mark them all as failed for this round
      for (final id in processedIds) {
        failedIds[id] = 1; // reset or increment
      }
    }

    for (final entry in failedIds.entries) {
      await db.update(
        'sync_queue',
        {
          'retryCount': entry.value,
          'lastAttemptedAt': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [entry.key],
      );
    }
  }

  Future<void> _markSynced(String type, Map<String, dynamic> payload) async {
    final id = payload['id'] as String?;
    if (id == null) return;

    final table = switch (type) {
      'loan' => 'loans',
      'farm' => 'farms',
      'farm_field' => 'farm_fields',
      'livestock' => 'livestock_records',
      'savings_transaction' => 'savings_transactions',
      'diagnosis' => 'diagnosis_results',
      'subsidy_application' => 'subsidy_applications',
      'marketplace_listing' => 'marketplace_listings',
      'marketplace_product' => 'marketplace_products',
      'user_profile' => 'farm_profile',
      'forum_post' => 'forum_posts',
      'iot_sensor' => 'iot_sensors',
      'worker' => 'farm_workers',
      'farm_task' => 'farm_tasks',
      _ => null,
    };

    if (table != null) {
      await db.update(table, {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> _addToBatch(String type, Map<String, dynamic> payload, WriteBatch batch) async {
    switch (type) {
      case 'loan':
        final loan = Loan(
          id: payload['id'],
          farmerId: payload['farmerId'],
          amount: (payload['amount'] as num).toDouble(),
          status: LoanStatus.pending,
          createdAt: DateTime.parse(payload['createdAt']),
          isSynced: false,
        );
        await loanRemote.sendLoan(loan); // This sends it instantly, outside batch for now (assume it has complex logic).

      case 'farm':
        final fullFarm = await _buildFarmDocument(payload['id'], payload);
        final ref = firestore.collection('farms').doc(payload['id']);
        batch.set(ref, fullFarm);

      case 'farm_field':
      case 'livestock':
        // When a nested entity changes, we pull and push the whole parent farm to embed it.
        final farmId = payload['farmId'] as String;
        final parentFarmList = await db.query('farms', where: 'id = ?', whereArgs: [farmId], limit: 1);
        if (parentFarmList.isNotEmpty) {
          final fullFarm = await _buildFarmDocument(farmId, parentFarmList.first);
          final ref = firestore.collection('farms').doc(farmId);
          batch.set(ref, fullFarm);
        }

      case 'savings_transaction':
        final ref = firestore.collection('savings_transactions').doc(payload['id']);
        batch.set(ref, payload);
        
      case 'group_order_join':
        final ref = firestore.collection('group_orders').doc(payload['orderId'])
            .collection('participants').doc(payload['farmerId']);
        batch.set(ref, payload);

      case 'contract_application':
        final ref = firestore.collection('farming_contracts').doc(payload['contractId'])
            .collection('applications').doc(payload['farmerId']);
        batch.set(ref, payload);

      case 'diagnosis':
        final ref = firestore.collection('diagnosis_results').doc(payload['id']);
        batch.set(ref, payload);

      case 'subsidy_application':
        final ref = firestore.collection('subsidy_applications').doc(payload['id']);
        batch.set(ref, payload);

      case 'marketplace_listing':
        final ref = firestore.collection('marketplace_listings').doc(payload['id']);
        batch.set(ref, payload);

      case 'marketplace_product':
        final ref = firestore.collection('marketplace_products').doc(payload['id']);
        batch.set(ref, payload);

      case 'marketplace_delete':
        final ref = firestore.collection('marketplace_products').doc(payload['id']);
        batch.delete(ref);

      case 'user_profile':
        final ref = firestore.collection('user_profiles').doc(payload['userId']);
        batch.set(ref, payload, SetOptions(merge: true));

      case 'forum_post':
        final ref = firestore.collection('forum_posts').doc(payload['id']);
        batch.set(ref, payload);

      case 'iot_sensor':
        final ref = firestore.collection('iot_sensors').doc(payload['id']);
        batch.set(ref, payload);

      case 'worker':
        final ref = firestore.collection('farm_workers').doc(payload['id']);
        batch.set(ref, payload);

      case 'farm_task':
        final ref = firestore.collection('farm_tasks').doc(payload['id']);
        batch.set(ref, payload);
    }
  }

  Future<Map<String, dynamic>> _buildFarmDocument(String farmId, Map<String, dynamic> baseData) async {
    final fields = await db.query('farm_fields', where: 'farmId = ?', whereArgs: [farmId]);
    final livestock = await db.query('livestock_records', where: 'farmId = ?', whereArgs: [farmId]);
    
    return {
      ...baseData,
      'crops': fields.map((f) => {
        'id': f['id'],
        'cropName': f['currentCrop'] ?? 'Unknown',
        'areHectares': (f['hectares'] as num?)?.toDouble() ?? 0.0,
        'status': f['status'] ?? 'planted',
        'plantedDate': DateTime.now().toIso8601String(), // Mock for now, would be stored in SQLite
        'expectedYield': (f['yieldTonnes'] as num?)?.toDouble(),
      }).toList(),
      'livestock': livestock.toList(),
    };
  }
}

