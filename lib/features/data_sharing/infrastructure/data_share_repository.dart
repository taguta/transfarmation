import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/data_share.dart';

/// Offline-first store for a farmer's sharing choices. SQLite is the source of
/// truth; each change is queued so it reaches the cloud when online.
class DataShareRepository {
  final Database db;
  DataShareRepository(this.db);

  Future<List<DataShare>> getShares(String farmerId) async {
    final rows = await db.query(
      'data_shares',
      where: 'farmerId = ?',
      whereArgs: [farmerId],
      orderBy: 'grantedAt DESC',
    );
    return rows.map(DataShare.fromMap).whereType<DataShare>().toList();
  }

  /// Shares [scopes] with [recipientName]. A scope that is already shared with
  /// that recipient is left as it is. Returns the shares now in force for them.
  Future<List<DataShare>> grant({
    required String farmerId,
    required String recipientName,
    required Iterable<ShareScope> scopes,
    String? recipientId,
    DateTime? now,
  }) async {
    final name = recipientName.trim();
    if (name.isEmpty) throw ArgumentError('A recipient is required');
    final at = now ?? DateTime.now();
    final existing = await getShares(farmerId);
    final result = <DataShare>[];

    await db.transaction((txn) async {
      for (final scope in scopes) {
        final current = existing.where((s) => s.isActive && s.isFor(name, scope));
        if (current.isNotEmpty) {
          result.add(current.first);
          continue;
        }
        final share = DataShare(
          id: '${farmerId}_${at.microsecondsSinceEpoch}_${scope.code}',
          farmerId: farmerId,
          recipientName: name,
          recipientId: recipientId,
          scope: scope,
          grantedAt: at,
          consentVersion: DataShare.currentConsentVersion,
        );
        await _save(txn, share);
        result.add(share);
      }
    });
    return result;
  }

  /// Stops sharing. The record is kept, marked revoked, as proof of what was
  /// shared and when.
  Future<void> revoke(String shareId, {DateTime? now}) async {
    final rows = await db.query('data_shares', where: 'id = ?', whereArgs: [shareId], limit: 1);
    if (rows.isEmpty) return;
    final share = DataShare.fromMap(rows.first);
    if (share == null || !share.isActive) return;
    final revoked = DataShare(
      id: share.id,
      farmerId: share.farmerId,
      recipientName: share.recipientName,
      recipientId: share.recipientId,
      scope: share.scope,
      grantedAt: share.grantedAt,
      revokedAt: now ?? DateTime.now(),
      consentVersion: share.consentVersion,
    );
    await db.transaction((txn) => _save(txn, revoked));
  }

  Future<void> _save(Transaction txn, DataShare s) async {
    await txn.insert(
      'data_shares',
      {...s.toMap(), 'isSynced': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // One queue row per share: a later revoke replaces the earlier grant, so
    // the cloud ends up with the latest state.
    await txn.insert('sync_queue', {
      'id': 'share_${s.id}',
      'type': 'data_share',
      'payload': jsonEncode({
        ...s.toMap(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      }),
      'retryCount': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
