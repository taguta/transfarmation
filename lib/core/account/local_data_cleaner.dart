import 'package:sqflite/sqflite.dart';

/// Removes one person's data from the device so the next person to sign in on
/// the same phone cannot see it.
///
/// Only per-farmer tables are cleared. Shared reference data (market prices,
/// experts, savings groups, service partners and so on) is left alone. The
/// sync queue and sync timestamps are cleared too: queued items belong to the
/// previous person and must never be sent under the next person's account, and
/// resetting the timestamps makes the next sign-in pull its own data afresh.
class LocalDataCleaner {
  static const userTables = <String>[
    'loans',
    'loan_payments',
    'farms',
    'farm_fields',
    'field_expenses',
    'livestock_records',
    'vet_events',
    'savings_transactions',
    'diagnosis_results',
    'farm_inputs',
    'subsidy_applications',
    'notifications',
    'farm_profile',
    'marketplace_listings',
    'farm_workers',
    'farm_tasks',
    'iot_sensors',
    'bookings',
    'feasibility_plans',
    'ledger_entries',
    'data_shares',
    'weather_alerts',
    'sync_queue',
    'sync_metadata',
  ];

  final Database db;
  LocalDataCleaner(this.db);

  /// Changes saved on this device that have not reached the cloud yet.
  Future<int> pendingChanges() async {
    try {
      return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM sync_queue')) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clearUserData() async {
    final existing = (await db.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'"))
        .map((r) => r['name'] as String)
        .toSet();
    await db.transaction((txn) async {
      for (final table in userTables) {
        if (existing.contains(table)) await txn.delete(table);
      }
    });
  }
}
