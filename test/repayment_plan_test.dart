import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:transfarmation/core/database/sqlite_service.dart';
import 'package:transfarmation/features/financing/domain/entities/loan.dart';
import 'package:transfarmation/features/financing/domain/repayment_plan.dart';
import 'package:transfarmation/features/financing/infrastructure/datasource/local/loan_sqlite.dart';

void main() {
  final start = DateTime(2026, 1, 15);
  final now = DateTime(2026, 4, 20);

  RepaymentPlan plan({double principal = 1200, int months = 6, double paid = 0}) =>
      RepaymentPlan.build(principal: principal, months: months, start: start, paid: paid, now: now);

  test('instalments add back up to the amount borrowed, even when it does not divide', () {
    final p = plan(principal: 1000, months: 3);
    final total = p.instalments.fold<double>(0, (s, i) => s + i.amount);
    expect(total, closeTo(1000, 0.001));
    expect(p.instalments.first.amount, 333.33);
    expect(p.instalments.last.amount, 333.34);
  });

  test('the first instalment is one month after the loan was applied for', () {
    expect(plan().instalments.first.dueDate, DateTime(2026, 2, 15));
    expect(plan().instalments.last.dueDate, DateTime(2026, 7, 15));
  });

  test('late-month start dates never roll into the next month', () {
    expect(RepaymentPlan.dueDateFor(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
  });

  test('payments fill the earliest instalments first, and unpaid past ones are overdue', () {
    final p = plan(paid: 300); // 200 clears the first, 100 goes towards the second
    expect(p.instalments[0].status, InstalmentStatus.paid);
    // Due 15 Mar and 15 Apr, both before "now" (20 Apr), neither fully paid.
    expect(p.instalments[1].status, InstalmentStatus.overdue);
    expect(p.instalments[1].remaining, 100);
    expect(p.instalments[2].status, InstalmentStatus.overdue);
    expect(p.instalments[3].status, InstalmentStatus.upcoming);
    expect(p.overdueCount, 2);
    expect(p.next!.number, 2);
    expect(p.outstanding, 900);
  });

  test('a future instalment that is part paid is partial, not overdue', () {
    final p = plan(paid: 700); // 3 paid (600) + 100 towards the 4th, due 15 May
    expect(p.instalments[3].status, InstalmentStatus.partial);
    expect(p.overdueCount, 0);
  });

  test('paying everything marks the loan paid off', () {
    final p = plan(paid: 1200);
    expect(p.isPaidOff, isTrue);
    expect(p.next, isNull);
    expect(p.outstanding, 0);
  });

  test('overpayment never makes the balance negative', () {
    expect(plan(paid: 5000).outstanding, 0);
  });

  test('reads the period text the apply screen writes', () {
    expect(RepaymentPlan.monthsFrom('12 months'), 12);
    expect(RepaymentPlan.monthsFrom('6'), 6);
    expect(RepaymentPlan.monthsFrom(null), 12);
    expect(RepaymentPlan.monthsFrom('whenever'), 12);
  });

  group('recorded payments', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('are stored, listed newest first, and reduce what a loan owes', () async {
      final dir = Directory.systemTemp.createTempSync('repayment_test');
      final db = await SqliteService.openAt(p.join(dir.path, 'agrolink.db'));
      addTearDown(() async {
        await db.close();
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
      });
      final local = LoanLocalDataSource(db);

      await local.saveLoan(Loan(
        id: 'l1',
        farmerId: 'f1',
        amount: 1200,
        status: LoanStatus.approved,
        createdAt: start,
        isSynced: true,
        repaymentPeriod: '6 months',
      ));
      await local.savePayment(LoanPayment(
          id: 'p1', loanId: 'l1', farmerId: 'f1', amount: 200, date: DateTime(2026, 2, 14), method: 'EcoCash'));
      await local.savePayment(LoanPayment(
          id: 'p2', loanId: 'l1', farmerId: 'f1', amount: 150, date: DateTime(2026, 3, 16), method: 'Cash'));

      final loan = (await local.getLoans('f1')).single;
      expect(loan.amountRepaid, 350);
      expect(loan.outstanding, 850);

      final payments = await local.getPayments('l1');
      expect(payments.map((p) => p.id), ['p2', 'p1']);
    });
  });
}
