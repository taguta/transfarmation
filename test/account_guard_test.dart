import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:transfarmation/core/account/account_guard.dart';
import 'package:transfarmation/core/account/local_data_cleaner.dart';
import 'package:transfarmation/core/database/sqlite_service.dart';
import 'package:transfarmation/features/ledger/domain/entities/ledger_entry.dart';
import 'package:transfarmation/features/ledger/infrastructure/repositories/ledger_repository.dart';

void main() {
  late Directory dir;
  late Database db;
  late LocalDataCleaner cleaner;
  String? owner;

  AccountGuard guard() => AccountGuard(
    cleaner,
    readOwner: () async => owner,
    writeOwner: (u) async => owner = u,
  );

  LedgerEntry entry(String id, String farmer) => LedgerEntry(
    id: id, farmerId: farmer, type: LedgerType.income, category: 'Crop sales',
    amount: 10, note: '', date: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    owner = null;
    dir = Directory.systemTemp.createTempSync('guard_test');
    db = await SqliteService.openAt(p.join(dir.path, 'agrolink.db'));
    cleaner = LocalDataCleaner(db);
  });

  tearDown(() async {
    await db.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<void> seedPersonA() async {
    await LedgerRepository(db).addEntry(entry('e1', 'A'));
    await db.insert('loans', {
      'id': 'l1', 'farmerId': 'A', 'amount': 100.0, 'status': 'pending',
      'createdAt': '2026-01-01T00:00:00.000', 'isSynced': 0,
    });
    await db.insert('sync_metadata', {'collection': 'loans', 'lastSyncAt': '2026-01-01T00:00:00.000'});
    // Shared reference data that must survive.
    await db.insert('commodity_prices', {
      'id': 'p1', 'commodityName': 'Maize', 'price': 300.0, 'unit': 'ton',
    });
  }

  test('the ledger only returns the signed-in farmer\'s entries', () async {
    final repo = LedgerRepository(db);
    await repo.addEntry(entry('a', 'A'));
    await repo.addEntry(entry('b', 'B'));
    expect((await repo.getEntries(farmerId: 'A')).map((e) => e.id), ['a']);
    expect((await repo.getEntries(farmerId: 'B')).map((e) => e.id), ['b']);
  });

  test('a different account signing in clears the previous person\'s data', () async {
    await seedPersonA();
    expect(await guard().reconcile('A'), isFalse); // first sign-in claims the device
    expect(await cleaner.pendingChanges(), greaterThan(0));

    expect(await guard().reconcile('B'), isTrue);
    expect(owner, 'B');
    expect(await db.query('ledger_entries'), isEmpty);
    expect(await db.query('loans'), isEmpty);
    expect(await db.query('sync_queue'), isEmpty, reason: 'A\'s queued items must never sync as B');
    expect(await db.query('sync_metadata'), isEmpty);
    expect(await db.query('commodity_prices'), hasLength(1), reason: 'shared data is kept');
  });

  test('the same account signing in again keeps its data', () async {
    await seedPersonA();
    await guard().reconcile('A');
    expect(await guard().reconcile('A'), isFalse);
    expect(await db.query('ledger_entries'), hasLength(1));
  });

  test('a device with no recorded owner is claimed, not wiped', () async {
    await seedPersonA();
    expect(await guard().reconcile('A'), isFalse);
    expect(owner, 'A');
    expect(await db.query('ledger_entries'), hasLength(1));
  });

  test('signed out (no uid) never clears anything', () async {
    await seedPersonA();
    await guard().reconcile('A');
    expect(await guard().reconcile(null), isFalse);
    expect(await db.query('ledger_entries'), hasLength(1));
  });

  test('sign-out clears the data and forgets the owner', () async {
    await seedPersonA();
    await guard().reconcile('A');
    await guard().clearForSignOut();
    expect(owner, isNull);
    expect(await db.query('ledger_entries'), isEmpty);
    expect(await cleaner.pendingChanges(), 0);
  });

  test('every table the cleaner names really exists, so none is silently skipped', () async {
    final names = (await db.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'"))
        .map((r) => r['name'] as String)
        .toSet();
    for (final t in LocalDataCleaner.userTables) {
      expect(names, contains(t), reason: t);
    }
  });
}
