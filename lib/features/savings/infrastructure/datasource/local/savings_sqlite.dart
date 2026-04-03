import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/savings_group.dart';

class SavingsLocalDataSource {
  final Database db;
  SavingsLocalDataSource(this.db);

  Future<void> saveGroup(SavingsGroup group) async {
    await db.insert('savings_groups', {
      'id': group.id,
      'name': group.name,
      'description': group.description,
      'contributionAmount': group.contributionAmount,
      'frequency': group.frequency,
      'memberCount': group.memberCount,
      'maxMembers': group.maxMembers,
      'status': group.status,
      'nextPayoutDate': group.nextPayoutDate.toIso8601String(),
      'nextRecipient': group.nextRecipient,
      'totalPool': group.totalPool,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SavingsGroup>> getGroups() async {
    final rows = await db.query('savings_groups');
    return rows
        .map(
          (r) => SavingsGroup(
            id: r['id'] as String,
            name: r['name'] as String,
            description: r['description'] as String? ?? '',
            contributionAmount: (r['contributionAmount'] as num).toDouble(),
            frequency: r['frequency'] as String,
            memberCount: r['memberCount'] as int? ?? 0,
            maxMembers: r['maxMembers'] as int? ?? 10,
            status: r['status'] as String? ?? 'active',
            nextPayoutDate: DateTime.parse(r['nextPayoutDate'] as String),
            nextRecipient: r['nextRecipient'] as String? ?? '',
            totalPool: (r['totalPool'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();
  }

  Future<void> saveTransaction(SavingsTransaction txn) async {
    await db.insert('savings_transactions', {
      'id': txn.id,
      'groupId': txn.groupId,
      'memberId': txn.memberId,
      'memberName': txn.memberName,
      'type': txn.type,
      'amount': txn.amount,
      'date': txn.date.toIso8601String(),
      'isConfirmed': txn.isConfirmed ? 1 : 0,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SavingsTransaction>> getTransactions(String groupId) async {
    final rows = await db.query(
      'savings_transactions',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );
    return rows
        .map(
          (r) => SavingsTransaction(
            id: r['id'] as String,
            groupId: r['groupId'] as String,
            memberId: r['memberId'] as String,
            memberName: r['memberName'] as String? ?? '',
            type: r['type'] as String,
            amount: (r['amount'] as num).toDouble(),
            date: DateTime.parse(r['date'] as String),
            isConfirmed: (r['isConfirmed'] as int?) == 1,
          ),
        )
        .toList();
  }
}
