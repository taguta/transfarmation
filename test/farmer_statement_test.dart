import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/financing/domain/entities/loan.dart';
import 'package:transfarmation/features/ledger/domain/entities/ledger_entry.dart';
import 'package:transfarmation/features/ledger/domain/farmer_statement.dart';

LedgerEntry _e(LedgerType t, String cat, double amt) => LedgerEntry(
  id: '$cat$amt', farmerId: 'f', type: t, category: cat, amount: amt,
  note: '', date: DateTime(2026, 1, 1),
);

Loan _loan(LoanStatus s, double amt, double repaid) => Loan(
  id: '$s$amt', farmerId: 'f', amount: amt, status: s,
  createdAt: DateTime(2026, 1, 1), isSynced: true, amountRepaid: repaid,
);

void main() {
  test('take-home is income minus costs minus outstanding active loans', () {
    final s = FarmerStatement.build(
      entries: [
        _e(LedgerType.income, 'Crop sales', 1000),
        _e(LedgerType.expense, 'Seed', 300),
        _e(LedgerType.expense, 'Labour', 100),
      ],
      loans: [
        _loan(LoanStatus.disbursed, 500, 100),
        _loan(LoanStatus.pending, 900, 0),
        _loan(LoanStatus.rejected, 700, 0),
      ],
    );
    expect(s.income, 1000);
    expect(s.costs, 400);
    expect(s.loanOutstanding, 400);
    expect(s.takeHome, 200);
    expect(s.isOwing, isFalse);
    expect(s.costsByCategory.keys.first, 'Seed');
  });

  test('negative balance is reported as owing', () {
    final s = FarmerStatement.build(
      entries: [_e(LedgerType.expense, 'Fertilizer', 800)],
      loans: [_loan(LoanStatus.approved, 200, 0)],
    );
    expect(s.takeHome, -1000);
    expect(s.isOwing, isTrue);
  });

  test('empty inputs give zeros', () {
    final s = FarmerStatement.build(entries: [], loans: []);
    expect(s.takeHome, 0);
    expect(s.costsByCategory, isEmpty);
  });
}
