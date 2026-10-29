import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:transfarmation/core/database/sqlite_service.dart';
import 'package:transfarmation/core/providers/data_providers.dart';
import 'package:transfarmation/features/auth/presentation/providers/auth_providers.dart';
import 'package:transfarmation/features/financing/domain/entities/loan.dart';
import 'package:transfarmation/features/financing/infrastructure/datasource/local/loan_sqlite.dart';
import 'package:transfarmation/features/financing/infrastructure/datasource/remote/loan_firestore.dart';
import 'package:transfarmation/features/financing/infrastructure/repositories/loan_repository_impl.dart';
import 'package:transfarmation/features/financing/presentation/screens/repayment_dashboard_screen.dart';

class _NoRemote extends Fake implements LoanRemoteDataSource {}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('recording a payment updates the balance, schedule and history', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final dir = Directory.systemTemp.createTempSync('repay_screen');
    late final LoanRepositoryImpl repo;
    late final dynamic db;
    await tester.runAsync(() async {
      db = await SqliteService.openAt(p.join(dir.path, 'agrolink.db'));
      final local = LoanLocalDataSource(db);
      repo = LoanRepositoryImpl(local, _NoRemote(), db);
      await local.saveLoan(Loan(
        id: 'l1',
        farmerId: 'f1',
        amount: 1200,
        status: LoanStatus.approved,
        // Far enough back that early instalments are due.
        createdAt: DateTime.now().subtract(const Duration(days: 75)),
        isSynced: true,
        repaymentPeriod: '6 months',
        purpose: 'Input Purchase',
        lenderName: 'Test Bank',
      ));
    });
    addTearDown(() async {
      await db.close();
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        activeFarmerIdProvider.overrideWithValue('f1'),
        loanRepositoryImplProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: RepaymentDashboardScreen()),
    ));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
    await tester.pump();

    // Nothing paid yet: the whole amount is owed, nothing in the history.
    expect(find.text(r'$1,200.00'), findsWidgets);
    expect(find.textContaining('No payments recorded yet'), findsOneWidget);
    expect(find.textContaining('overdue'), findsWidgets);

    await tester.tap(find.text('Record a payment'));
    await tester.pumpAndSettle();

    // Zero is rejected with a message and nothing is saved.
    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.text('Save payment'));
    await tester.pump();
    expect(find.text('Enter the amount you paid.'), findsOneWidget);

    // More than is owed is rejected.
    await tester.enterText(find.byType(TextField), '5000');
    await tester.tap(find.text('Save payment'));
    await tester.pump();
    expect(find.textContaining('more than the'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '350');
    await tester.runAsync(() async {
      await tester.tap(find.text('Save payment'));
      await Future.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    // The providers reload from SQLite, which needs real time to complete.
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 150)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    expect(find.text(r'$850.00'), findsWidgets); // outstanding
    expect(find.text(r'$350.00'), findsWidgets); // paid / history
    expect(find.textContaining('No payments recorded yet'), findsNothing);
    expect(find.textContaining('EcoCash'), findsOneWidget);

    // The payment was queued for the cloud with the farmer's id.
    final queued = await tester.runAsync(() => db.query('sync_queue', where: "type = 'loan_payment'"));
    expect(queued, hasLength(1));
  });
}
