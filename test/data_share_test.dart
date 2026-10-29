import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:transfarmation/core/database/sqlite_service.dart';
import 'package:transfarmation/features/data_sharing/domain/data_share.dart';
import 'package:transfarmation/features/data_sharing/infrastructure/data_share_repository.dart';

void main() {
  late Directory dir;
  late Database db;
  late DataShareRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('share_test');
    db = await SqliteService.openAt(p.join(dir.path, 'agrolink.db'));
    repo = DataShareRepository(db);
  });

  tearDown(() async {
    await db.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('granting shares only the chosen scopes with that recipient', () async {
    await repo.grant(
      farmerId: 'f1',
      recipientName: 'Example Bank',
      scopes: [ShareScope.loanFile, ShareScope.ledgerSummary],
    );
    final shares = await repo.getShares('f1');
    expect(shares, hasLength(2));
    expect(DataSharing.allows(shares, 'example bank ', ShareScope.loanFile), isTrue);
    expect(DataSharing.allows(shares, 'Example Bank', ShareScope.farmLocation), isFalse);
    expect(DataSharing.allows(shares, 'Other Bank', ShareScope.loanFile), isFalse);
  });

  test('sharing the same scope with the same recipient twice does not duplicate it', () async {
    await repo.grant(farmerId: 'f1', recipientName: 'Bank', scopes: [ShareScope.plan]);
    await repo.grant(farmerId: 'f1', recipientName: ' bank ', scopes: [ShareScope.plan]);
    expect(await repo.getShares('f1'), hasLength(1));
  });

  test('revoking stops access but keeps the record', () async {
    final granted = await repo.grant(
      farmerId: 'f1', recipientName: 'Bank', scopes: [ShareScope.plan],
    );
    await repo.revoke(granted.single.id);
    final shares = await repo.getShares('f1');
    expect(shares, hasLength(1));
    expect(shares.single.isActive, isFalse);
    expect(DataSharing.allows(shares, 'Bank', ShareScope.plan), isFalse);
  });

  test('granting again after a revoke creates a new grant and keeps the history', () async {
    final first = await repo.grant(
      farmerId: 'f1', recipientName: 'Bank', scopes: [ShareScope.plan],
      now: DateTime(2026, 1, 1),
    );
    await repo.revoke(first.single.id, now: DateTime(2026, 1, 2));
    await repo.grant(
      farmerId: 'f1', recipientName: 'Bank', scopes: [ShareScope.plan],
      now: DateTime(2026, 1, 3),
    );
    final shares = await repo.getShares('f1');
    expect(shares, hasLength(2));
    expect(shares.where((s) => s.isActive), hasLength(1));
  });

  test("one farmer never sees another farmer's shares", () async {
    await repo.grant(farmerId: 'f1', recipientName: 'Bank', scopes: [ShareScope.plan]);
    expect(await repo.getShares('f2'), isEmpty);
  });

  test('each change is queued for sync, and a revoke replaces the queued grant', () async {
    final granted = await repo.grant(
      farmerId: 'f1', recipientName: 'Bank', scopes: [ShareScope.plan],
    );
    var queue = await db.query('sync_queue', where: "type = 'data_share'");
    expect(queue, hasLength(1));
    expect(jsonDecode(queue.single['payload'] as String)['revokedAt'], isNull);

    await repo.revoke(granted.single.id);
    queue = await db.query('sync_queue', where: "type = 'data_share'");
    expect(queue, hasLength(1));
    expect(jsonDecode(queue.single['payload'] as String)['revokedAt'], isNotNull);
  });

  test('a recipient is required', () async {
    expect(
      () => repo.grant(farmerId: 'f1', recipientName: '  ', scopes: [ShareScope.plan]),
      throwsArgumentError,
    );
  });
}
