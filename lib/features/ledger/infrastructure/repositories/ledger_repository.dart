import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/ledger_entry.dart';

/// Offline-first ledger: SQLite is the source of truth, writes are queued for sync.
class LedgerRepository {
  final Database db;
  LedgerRepository(this.db);

  Future<List<LedgerEntry>> getEntries() async {
    final rows = await db.query('ledger_entries', orderBy: 'date DESC');
    return rows.map(LedgerEntry.fromMap).toList();
  }

  Future<void> addEntry(LedgerEntry e) => addEntries([e]);

  /// Saves several entries in one transaction (e.g. the lines of a sale).
  Future<void> addEntries(List<LedgerEntry> entries) async {
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      for (final e in entries) {
        await txn.insert('ledger_entries', {...e.toMap(), 'isSynced': 0},
            conflictAlgorithm: ConflictAlgorithm.replace);
        await txn.insert('sync_queue', {
          'id': 'ledger_${e.id}',
          'type': 'ledger_entry',
          'payload': jsonEncode({...e.toMap(), 'updatedAt': now}),
          'retryCount': 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        // A re-saved entry cancels any pending delete for it.
        await txn.delete('sync_queue', where: 'id = ?', whereArgs: ['ledger_del_${e.id}']);
      }
    });
  }

  /// Deletes an entry, and the rest of its group (e.g. all lines of one sale).
  /// The cloud copy is removed too: a queued delete is sent on the next sync.
  Future<void> deleteEntry(String id) async {
    final row = await db.query('ledger_entries', where: 'id = ?', whereArgs: [id], limit: 1);
    if (row.isEmpty) return;
    final groupId = row.first['groupId'] as String?;
    final victims = groupId == null
        ? row
        : await db.query('ledger_entries', where: 'groupId = ?', whereArgs: [groupId]);

    await db.transaction((txn) async {
      for (final v in victims) {
        final vid = v['id'] as String;
        await txn.delete('ledger_entries', where: 'id = ?', whereArgs: [vid]);
        await txn.delete('sync_queue', where: 'id = ?', whereArgs: ['ledger_$vid']);
        await txn.insert('sync_queue', {
          'id': 'ledger_del_$vid',
          'type': 'ledger_delete',
          'payload': jsonEncode({'id': vid}),
          'retryCount': 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
