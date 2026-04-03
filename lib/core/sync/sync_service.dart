import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/financing/infrastructure/datasource/remote/loan_firestore.dart';
import '../../features/financing/domain/entities/loan.dart';

/// Processes the sync_queue table, retrying failed remote writes.
/// Handles all entity types: loan, farm, savings_transaction,
/// group_order_join, contract_application, diagnosis, subsidy_application.
///
/// Uses exponential backoff: a queue item with retryCount N waits at least
/// 2^N minutes before the next attempt.
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

    for (final item in items) {
      final retryCount = item['retryCount'] as int;
      final lastAttemptedAt = item['lastAttemptedAt'] as String?;

      // Exponential backoff: skip if not enough time has elapsed since last attempt.
      if (lastAttemptedAt != null) {
        final lastAttempt = DateTime.parse(lastAttemptedAt);
        final backoffSeconds = pow(2, retryCount).toInt() * 60; // 2^n minutes
        if (now.difference(lastAttempt).inSeconds < backoffSeconds) {
          continue;
        }
      }

      try {
        final type = item['type'] as String;
        final payload =
            jsonDecode(item['payload'] as String) as Map<String, dynamic>;

        await _processItem(type, payload);
        await _markSynced(type, payload);

        await db.delete(
          'sync_queue',
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      } catch (_) {
        await db.update(
          'sync_queue',
          {
            'retryCount': retryCount + 1,
            'lastAttemptedAt': now.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }
  }

  /// Flips isSynced = 1 on the local SQLite row after a successful remote write.
  /// Types that write to subcollections only (group_order_join, contract_application)
  /// have no top-level local row to mark, so they are skipped.
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
      _ => null, // group_order_join, contract_application — subcollections only
    };

    if (table != null) {
      await db.update(
        table,
        {'isSynced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> _processItem(String type, Map<String, dynamic> payload) async {
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
        await loanRemote.sendLoan(loan);

      case 'farm':
        await firestore.collection('farms').doc(payload['id']).set(payload);

      case 'savings_transaction':
        await firestore
            .collection('savings_transactions')
            .doc(payload['id'])
            .set(payload);

      case 'group_order_join':
        await firestore
            .collection('group_orders')
            .doc(payload['orderId'])
            .collection('participants')
            .doc(payload['farmerId'])
            .set(payload);

      case 'contract_application':
        await firestore
            .collection('farming_contracts')
            .doc(payload['contractId'])
            .collection('applications')
            .doc(payload['farmerId'])
            .set(payload);

      case 'diagnosis':
        await firestore
            .collection('diagnosis_results')
            .doc(payload['id'])
            .set(payload);

      case 'subsidy_application':
        await firestore
            .collection('subsidy_applications')
            .doc(payload['id'])
            .set(payload);

      case 'farm_field':
        await firestore
            .collection('farms')
            .doc(payload['farmId'])
            .collection('fields')
            .doc(payload['id'])
            .set(payload);

      case 'livestock':
        await firestore
            .collection('farms')
            .doc(payload['farmId'])
            .collection('livestock')
            .doc(payload['id'])
            .set(payload);
    }
  }
}
