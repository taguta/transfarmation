import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' show Sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:transfarmation/core/database/sqlite_service.dart';
import 'package:transfarmation/features/diagnosis/domain/entities/diagnosis.dart';
import 'package:transfarmation/features/diagnosis/infrastructure/datasource/local/diagnosis_sqlite.dart';
import 'package:transfarmation/features/feasibility/domain/entities/feasibility_plan.dart';
import 'package:transfarmation/features/feasibility/domain/services/feasibility_calculator.dart';
import 'package:transfarmation/features/feasibility/infrastructure/datasource/local/feasibility_sqlite.dart';
import 'package:transfarmation/features/financing/domain/entities/loan.dart';
import 'package:transfarmation/features/financing/infrastructure/datasource/local/loan_sqlite.dart';
import 'package:transfarmation/features/ledger/domain/entities/ledger_entry.dart';
import 'package:transfarmation/features/ledger/domain/sale_settlement.dart';
import 'package:transfarmation/features/ledger/infrastructure/repositories/ledger_repository.dart';

/// Columns each migration added, by table. Used to rebuild an old database by
/// removing them from a real, current schema, so this list is the only thing
/// that has to be kept in step with the migrations.
const _addedColumns = <String, List<String>>{
  'diagnosis_results': [
    'subjectName', 'notes', 'matchCount', 'symptoms', 'escalatedAt',
    'topMatchDescription', 'expertReply', 'repliedAt',
  ],
  'loans': [
    'farmName', 'province', 'farmSize', 'cropType', 'farmingType', 'purpose',
    'repaymentPeriod', 'amountRepaid', 'lenderName', 'decisionNote', 'planSummary',
  ],
  'loan_offers': ['isSample', 'lenderId'],
  'weather_alerts': ['type', 'timestamp', 'isSynced'],
};

/// Tables that did not exist at v7 (feasibility and ledger in v8, loan payments in v15).
const _tablesAddedInV8 = ['feasibility_plans', 'ledger_entries', 'loan_payments'];

Future<Set<String>> _columns(Database db, String table) async =>
    (await db.rawQuery('PRAGMA table_info($table)')).map((r) => r['name'] as String).toSet();

Future<int> _version(Database db) async =>
    Sqflite.firstIntValue(await db.rawQuery('PRAGMA user_version')) ?? 0;

void main() {
  late Directory dir;
  late String path;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    dir = Directory.systemTemp.createTempSync('migration_test');
    path = p.join(dir.path, 'agrolink.db');
  });

  tearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  /// Builds a database as it was at schema v7, with a row in each table that
  /// later migrations change.
  Future<void> createV7Database() async {
    final db = await SqliteService.openAt(path);
    for (final e in _addedColumns.entries) {
      for (final c in e.value) {
        await db.execute('ALTER TABLE ${e.key} DROP COLUMN $c');
      }
    }
    for (final t in _tablesAddedInV8) {
      await db.execute('DROP TABLE $t');
    }
    await db.execute('DROP TABLE IF EXISTS data_shares');
    await db.insert('loans', {
      'id': 'old-loan', 'farmerId': 'f1', 'amount': 750.0, 'status': 'approved',
      'createdAt': '2026-01-01T00:00:00.000', 'isSynced': 1,
    });
    await db.insert('diagnosis_results', {
      'id': 'old-diag', 'type': 'crop', 'timestamp': '2026-01-02T00:00:00.000',
      'topMatchName': 'Fall Armyworm', 'topMatchConfidence': 0.7, 'isSynced': 1,
    });
    await db.insert('loan_offers', {
      'id': 'old-offer', 'lenderName': 'Old Bank', 'interestRate': 12.0, 'amount': 1000.0,
      'repaymentPeriod': '6 months', 'monthlyPayment': 180.0, 'conditions': 'none',
    });
    await db.insert('weather_alerts', {'id': 'old-alert', 'title': 'Old alert', 'region': 'X'});
    await db.execute('PRAGMA user_version = 7');
    await db.close();
  }

  group('schema', () {
    test('a fresh install has every table and migrated column', () async {
      final db = await SqliteService.openAt(path);
      expect(await _version(db), SqliteService.schemaVersion);
      for (final e in _addedColumns.entries) {
        expect(await _columns(db, e.key), containsAll(e.value), reason: e.key);
      }
      for (final t in _tablesAddedInV8) {
        expect((await _columns(db, t)), isNotEmpty, reason: t);
      }
      expect(await _columns(db, 'ledger_entries'), contains('groupId'));
      await db.close();
    });

    test('the test really rebuilds a v7 database (guards the helper)', () async {
      await createV7Database();
      final db = await databaseFactory.openDatabase(path);
      expect(await _version(db), 7);
      expect(await _columns(db, 'loans'), isNot(contains('planSummary')));
      expect(await _columns(db, 'loans'), contains('amount'));
      expect(await _columns(db, 'ledger_entries'), isEmpty);
      await db.close();
    });

    test('upgrading from v7 adds the columns and tables and keeps existing rows', () async {
      await createV7Database();
      final db = await SqliteService.openAt(path);

      expect(await _version(db), SqliteService.schemaVersion);
      for (final e in _addedColumns.entries) {
        expect(await _columns(db, e.key), containsAll(e.value), reason: e.key);
      }
      for (final t in _tablesAddedInV8) {
        expect(await _columns(db, t), isNotEmpty, reason: t);
      }
      expect(await _columns(db, 'data_shares'), containsAll(['recipientName', 'scope', 'revokedAt']));

      final loan = (await db.query('loans', where: 'id = ?', whereArgs: ['old-loan'])).single;
      expect(loan['amount'], 750.0);
      expect(loan['status'], 'approved');
      expect(loan['planSummary'], isNull);
      expect((await db.query('diagnosis_results')).single['topMatchName'], 'Fall Armyworm');
      expect((await db.query('loan_offers')).single['lenderName'], 'Old Bank');
      expect((await db.query('weather_alerts')).single['title'], 'Old alert');
      await db.close();
    });

    test('reopening an up-to-date database keeps its data', () async {
      var db = await SqliteService.openAt(path);
      await db.insert('loans', {
        'id': 'l1', 'farmerId': 'f', 'amount': 5.0, 'status': 'pending',
        'createdAt': '2026-01-01T00:00:00.000', 'isSynced': 0,
      });
      await db.close();

      db = await SqliteService.openAt(path);
      expect(await _version(db), SqliteService.schemaVersion);
      expect(await db.query('loans'), hasLength(1));
      await db.close();
    });
  });

  // The app's own data-access code must agree with the schema on both paths.
  for (final scenario in ['fresh install', 'upgraded from v7']) {
    group('data access on a $scenario', () {
      late Database db;

      setUp(() async {
        if (scenario != 'fresh install') await createV7Database();
        db = await SqliteService.openAt(path);
      });

      tearDown(() => db.close());

      test('a full loan application round-trips', () async {
        final ds = LoanLocalDataSource(db);
        await ds.saveLoan(Loan(
          id: 'l1', farmerId: 'f1', amount: 1200, status: LoanStatus.pending,
          createdAt: DateTime(2026, 3, 1), isSynced: false,
          farmName: 'Moyo Farm', province: 'Mashonaland East', farmSize: 4.5,
          cropType: 'Tobacco', farmingType: 'Rainfed', purpose: 'Inputs',
          repaymentPeriod: '12 months',
          planSummary: {'revenue': 6000.0, 'dscr': 1.4, 'warnings': ['x']},
        ));
        final loans = await ds.getLoans('f1');
        final back = loans.firstWhere((l) => l.id == 'l1');
        if (scenario != 'fresh install') {
          // The loan that existed before the upgrade still reads back, with empty new fields.
          final old = loans.firstWhere((l) => l.id == 'old-loan');
          expect(old.amount, 750);
          expect(old.farmName, isNull);
          expect(old.amountRepaid, 0);
        }
        expect(back.farmName, 'Moyo Farm');
        expect(back.farmSize, 4.5);
        expect(back.purpose, 'Inputs');
        expect(back.planSummary?['dscr'], 1.4);
        expect(back.planSummary?['warnings'], ['x']);
      });

      test('loan offers can be replaced and read back with sample flags', () async {
        final ds = LoanLocalDataSource(db);
        await ds.replaceOffers([
          {
            'id': 'o1', 'lenderName': 'Bank', 'lenderId': 'sample', 'interestRate': 18.0,
            'amount': 3000.0, 'repaymentPeriod': '9 months', 'monthlyPayment': 360.0,
            'conditions': 'c', 'isRecommended': 1, 'isSample': 1,
          },
        ]);
        final offer = (await ds.getLoanOffers()).single;
        expect(offer.isSample, isTrue);
        expect(offer.isRecommended, isTrue);
        expect(offer.lenderId, 'sample');
      });

      test('a diagnosis with symptoms and a reply round-trips', () async {
        final ds = DiagnosisLocalDataSource(db);
        await ds.saveDiagnosis(DiagnosisResult(
          id: 'd1', type: 'livestock', imagePath: '', subjectName: 'Goat',
          timestamp: DateTime(2026, 3, 2), symptoms: const ['Drooling', 'Lameness'],
          matches: const [
            DiagnosisMatch(
              name: 'Foot and Mouth Disease', confidence: 0.6, description: 'd',
              severity: 'critical', treatment: 't', prevention: 'p',
            ),
          ],
        ));
        await ds.markEscalated('d1', DateTime(2026, 3, 3));
        await db.update('diagnosis_results', {'expertReply': 'Isolate it'}, where: 'id = ?', whereArgs: ['d1']);

        final back = (await ds.getDiagnosisHistory()).firstWhere((d) => d.id == 'd1');
        expect(back.subjectName, 'Goat');
        expect(back.symptoms, ['Drooling', 'Lameness']);
        expect(back.isEscalated, isTrue);
        expect(back.expertReply, 'Isolate it');
        expect(back.matches.single.severity, 'critical');
      });

      test('a feasibility plan round-trips', () async {
        final t = tobaccoTemplate;
        final inputs = FeasibilityInputs(
          crop: 'Tobacco', hectares: 2, yieldKgPerHa: t.yieldKgPerHa, pricePerKg: t.pricePerKg,
          costPerHa: t.costPerHa, levyPct: t.levyPct, loanAmount: 2000, annualInterestPct: 18,
          loanTermMonths: 18, graceMonths: 8, ownContribution: 0, startDate: DateTime(2026, 10),
        );
        final ds = FeasibilityLocalDataSource(db);
        await ds.save(FeasibilityPlan(
          id: 'p1', farmerId: 'f1', inputs: inputs, createdAt: DateTime(2026, 3, 4),
        ));
        final back = (await ds.getAll()).single;
        expect(back.inputs.hectares, 2);
        expect(back.inputs.costPerHa, t.costPerHa);
      });

      test('a recorded sale is saved as linked ledger lines and deleted as one', () async {
        final repo = LedgerRepository(db);
        const sale = SaleSettlement(kg: 1000, pricePerKg: 3, levyPct: 2, loanDeduction: 500);
        await repo.addEntries(sale.toEntries(
          groupId: 'g1', farmerId: 'f1', crop: 'Tobacco', buyer: 'Acme', date: DateTime(2026, 4, 1),
        ));

        final entries = await repo.getEntries();
        expect(entries, hasLength(3));
        expect(entries.every((e) => e.groupId == 'g1'), isTrue);
        expect(LedgerSummary.of(entries).balance, closeTo(sale.net, 1e-9));
        expect(await db.query('sync_queue', where: "type = 'ledger_entry'"), hasLength(3));

        await repo.deleteEntry(entries.first.id);

        expect(await repo.getEntries(), isEmpty);
        expect(await db.query('sync_queue', where: "type = 'ledger_entry'"), isEmpty);
        expect(await db.query('sync_queue', where: "type = 'ledger_delete'"), hasLength(3));
      });

      test('re-saving an entry cancels its queued cloud delete', () async {
        final repo = LedgerRepository(db);
        final e = LedgerEntry(
          id: 'e1', farmerId: 'f1', type: LedgerType.income, category: 'Crop sales',
          amount: 10, note: '', date: DateTime(2026, 4, 1),
        );
        await repo.addEntry(e);
        await repo.deleteEntry('e1');
        expect(await db.query('sync_queue', where: "id = 'ledger_del_e1'"), hasLength(1));

        await repo.addEntry(e);
        expect(await db.query('sync_queue', where: "id = 'ledger_del_e1'"), isEmpty);
        expect(await repo.getEntries(), hasLength(1));
      });
    });
  }
}
