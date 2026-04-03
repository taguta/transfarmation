import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../datasource/remote/loan_firestore.dart';
import '../../domain/entities/loan.dart';

/// Processes the sync_queue table, retrying failed remote writes.
/// Handles all entity types: loan, farm, savings_transaction,
/// group_order_join, contract_application, diagnosis, subsidy_application.
class SyncService {
  final Database db;
  final LoanRemoteDataSource loanRemote;
  final FirebaseFirestore firestore;

  SyncService(this.db, this.loanRemote, this.firestore);

  Future<void> processQueue() async {
    final items = await db.query(
      'sync_queue',
      where: 'retryCount < ?',
      whereArgs: [10],
    );

    for (final item in items) {
      try {
        final type = item['type'] as String;
        final payload =
            jsonDecode(item['payload'] as String) as Map<String, dynamic>;

        await _processItem(type, payload);

        await db.delete('sync_queue', where: 'id = ?', whereArgs: [item['id']]);
      } catch (_) {
        await db.update(
          'sync_queue',
          {'retryCount': (item['retryCount'] as int) + 1},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
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
    }
  }
}
