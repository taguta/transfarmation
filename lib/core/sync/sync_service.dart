import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/financing/infrastructure/datasource/remote/loan_firestore.dart';

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
      // A Firestore batch holds at most 500 writes; leave headroom and let the
      // next run pick up the rest.
      limit: 400,
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

        // Conflict Resolution Check
        bool isConflicted = false;
        try {
          if (payload.containsKey('id') && payload.containsKey('updatedAt')) {
             final collection = _getCollectionForType(type);
             if (collection != null) {
               final remoteDoc = await firestore.collection(collection).doc(payload['id']).get();
               if (remoteDoc.exists) {
                 final remoteUpdatedAt = DateTime.parse(remoteDoc.data()?['updatedAt'] ?? '1970-01-01');
                 final localUpdatedAt = DateTime.parse(payload['updatedAt']);
                 if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
                    isConflicted = true; // Remote changes override this local write
                 }
               }
             }
          }
        } catch (_) {}

        if (!isConflicted) {
           await _addToBatch(type, payload, batch);
        }
        processedIds.add(item['id'] as String);
        await _markSynced(type, payload);
      } on StateError {
        // Signed out: keep the item queued without using up a retry.
        continue;
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
      final counts = {
        for (final i in items) i['id'] as String: i['retryCount'] as int,
      };
      for (final id in processedIds) {
        failedIds[id] = (counts[id] ?? 0) + 1;
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
      'feasibility_plan' => 'feasibility_plans',
      'ledger_entry' => 'ledger_entries',
      _ => null,
    };

    if (table != null) {
      await db.update(table, {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
    }
  }

  /// Stamps the signed-in user as owner so per-user rules and queries work.
  /// Throws when signed out, which leaves the item in the queue for a retry.
  Map<String, dynamic> _owned(Map<String, dynamic> payload) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Sign in to sync this item');
    return {
      ...payload,
      'farmerId': uid,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _addToBatch(String type, Map<String, dynamic> payload, WriteBatch batch) async {
    switch (type) {
      case 'loan':
        final ref = firestore.collection('loans').doc(payload['id']);
        batch.set(ref, _owned(payload));

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
        batch.set(ref, _owned(payload));

      case 'diagnosis_escalation':
        final ref = firestore.collection('diagnosis_escalations').doc(payload['id']);
        batch.set(ref, _owned(payload));

      case 'subsidy_application':
        final ref = firestore.collection('subsidy_applications').doc(payload['id']);
        batch.set(ref, _owned(payload));

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
        final ref = firestore.collection('users').doc(payload['userId']);
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

      case 'booking':
        final ref = firestore.collection('bookings').doc(payload['id']);
        batch.set(ref, payload);

      case 'feasibility_plan':
        final ref = firestore.collection('feasibility_plans').doc(payload['id']);
        batch.set(ref, payload);

      case 'ledger_entry':
        final ref = firestore.collection('ledger_entries').doc(payload['id']);
        batch.set(ref, _owned(payload));

      case 'savings_group_join':
        final ref = firestore
            .collection('savings_group_members')
            .doc('${payload['groupId']}_${payload['farmerId']}');
        batch.set(ref, _owned(payload));

      // Read state for notifications lives on the device only for now.
      case 'notification_read':
      case 'notification_mark_all_read':
        break;

      case 'data_deletion_request':
        final ref = firestore.collection('deletion_requests').doc(payload['id']);
        batch.set(ref, _owned(payload));

      case 'ledger_delete':
        batch.delete(firestore.collection('ledger_entries').doc(payload['id']));

      default:
        // Never drop an item we do not understand: fail it so it stays queued.
        throw ArgumentError('Unknown sync type: $type');
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

  String? _getCollectionForType(String type) {
    return switch (type) {
      'marketplace_listing' => 'marketplace_listings',
      'marketplace_product' => 'marketplace_products',
      'user_profile' => 'users',
      'forum_post' => 'forum_posts',
      'iot_sensor' => 'iot_sensors',
      'worker' => 'farm_workers',
      'farm_task' => 'farm_tasks',
      'feasibility_plan' => 'feasibility_plans',
      'ledger_entry' => 'ledger_entries',
      _ => null,
    };
  }

  /// Initial Downward Hydration: Pulls state from Firebase locally on boot or reconnect
  Future<void> hydrateInitialData() async {
    final definitions = [
      {
        'collection': 'users', 
        'table': 'farm_profile', 
        'mapper': (Map<String, dynamic> doc, String id) => {'id': id, 'data': jsonEncode(doc)} 
      },
      {
        'collection': 'marketplace_products', 
        'table': 'marketplace_products', 
        'mapper': (Map<String, dynamic> doc, String id) => {
          'id': id,
          'sellerId': doc['sellerId'] ?? '',
          'title': doc['title'] ?? '',
          'description': doc['description'] ?? '',
          'price': (doc['price'] ?? 0.0).toDouble(),
          'category': doc['category'] ?? '',
          'imageUrls': jsonEncode(doc['imageUrls'] ?? []),
          'postedAt': doc['postedAt'] ?? DateTime.now().toIso8601String(),
          'isSynced': 1
        }
      },
    ];

    for (var def in definitions) {
      final collection = def['collection'] as String;
      final table = def['table'] as String;
      final mapper = def['mapper'] as Map<String, dynamic> Function(Map<String, dynamic>, String);

      final metadata = await db.query('sync_metadata', where: 'collection = ?', whereArgs: [collection]);
      DateTime? lastSync;
      if (metadata.isNotEmpty) {
        lastSync = DateTime.tryParse(metadata.first['lastSyncAt'] as String);
      }

      Query query = firestore.collection(collection);
      if (lastSync != null) {
        query = query.where('updatedAt', isGreaterThan: lastSync.toIso8601String());
      }
      
      try {
        final snapshot = await query.get();
        for (final docInfo in snapshot.docs) {
           final mappedData = mapper(docInfo.data() as Map<String, dynamic>, docInfo.id);
           await db.insert(table, mappedData, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await db.insert('sync_metadata', {
          'collection': collection,
          'lastSyncAt': DateTime.now().toIso8601String()
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (_) {}
    }
  }
}

