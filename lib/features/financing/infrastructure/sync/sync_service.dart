
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../datasource/remote/loan_firestore.dart';
import '../../domain/entities/loan.dart';

class SyncService {
  final Database db;
  final LoanRemoteDataSource remote;

  SyncService(this.db, this.remote);

  Future<void> processQueue() async {
    final items = await db.query('sync_queue');

    for (var item in items) {
      try {
        final payload = jsonDecode(item['payload'] as String);

        final loan = Loan(
          id: payload['id'],
          farmerId: payload['farmerId'],
          amount: payload['amount'],
          status: LoanStatus.pending,
          createdAt: DateTime.parse(payload['createdAt']),
          isSynced: false,
        );

        await remote.sendLoan(loan);

        await db.delete('sync_queue', where: 'id=?', whereArgs: [item['id']]);
      } catch (_) {
        await db.update('sync_queue', {
          'retryCount': (item['retryCount'] as int) + 1
        }, where: 'id=?', whereArgs: [item['id']]);
      }
    }
  }
}
