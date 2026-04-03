import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/savings_group.dart';
import '../../domain/repositories/savings_repository.dart';
import '../datasource/local/savings_sqlite.dart';
import '../datasource/remote/savings_firestore.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final SavingsLocalDataSource local;
  final SavingsRemoteDataSource remote;
  final Database db;

  SavingsRepositoryImpl(this.local, this.remote, this.db);

  @override
  Future<List<SavingsGroup>> getGroups(String farmerId) async {
    // Try to fetch from remote first, cache locally
    try {
      final groups = await remote.fetchGroups();
      for (final g in groups) {
        await local.saveGroup(g);
      }
      return groups;
    } catch (_) {
      return local.getGroups();
    }
  }

  @override
  Future<void> joinGroup(String groupId, String farmerId) async {
    // Server-only action, no local state change
    try {
      // Would call remote.joinGroup() if we had that method
    } catch (_) {
      // Queue for later
    }
  }

  @override
  Future<void> recordTransaction(SavingsTransaction transaction) async {
    await local.saveTransaction(transaction);
    try {
      await remote.sendTransaction(transaction);
      await db.update('savings_transactions', {'isSynced': 1}, where: 'id = ?', whereArgs: [transaction.id]);
    } catch (_) {
      await db.insert('sync_queue', {
        'id': transaction.id,
        'type': 'savings_transaction',
        'payload': jsonEncode({
          'id': transaction.id,
          'groupId': transaction.groupId,
          'memberId': transaction.memberId,
          'memberName': transaction.memberName,
          'type': transaction.type,
          'amount': transaction.amount,
          'date': transaction.date.toIso8601String(),
        }),
        'retryCount': 0,
      });
    }
  }

  @override
  Future<List<SavingsTransaction>> getTransactions(String groupId) {
    return local.getTransactions(groupId);
  }
}
