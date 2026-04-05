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
    return local.getGroups();
  }

  @override
  Future<void> joinGroup(String groupId, String farmerId) async {
    // Write queue for server to process join
    await db.insert('sync_queue', {
      'id': '${groupId}_$farmerId',
      'type': 'savings_group_join',
      'payload': jsonEncode({
        'groupId': groupId,
        'farmerId': farmerId,
      }),
      'retryCount': 0,
    });
  }

  @override
  Future<void> recordTransaction(SavingsTransaction transaction) async {
    await local.saveTransaction(transaction);
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

  @override
  Future<List<SavingsTransaction>> getTransactions(String groupId) {
    return local.getTransactions(groupId);
  }
}

