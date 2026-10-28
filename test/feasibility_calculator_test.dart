import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/feasibility/domain/entities/feasibility_plan.dart';
import 'package:transfarmation/features/feasibility/domain/services/feasibility_calculator.dart';

FeasibilityInputs _inputs({double loan = 3000, double price = 3.0}) => FeasibilityInputs(
  crop: 'Tobacco',
  hectares: 1,
  yieldKgPerHa: 2000,
  pricePerKg: price,
  costPerHa: tobaccoTemplate.costPerHa,
  levyPct: 2,
  loanAmount: loan,
  annualInterestPct: 18,
  loanTermMonths: 18,
  graceMonths: 8,
  ownContribution: 0,
  startDate: DateTime(2026, 10),
);

void main() {
  test('produces 24 months and revenue for two tobacco cycles', () {
    final r = FeasibilityCalculator.compute(_inputs());
    expect(r.months.length, 24);
    expect(r.totalRevenue, closeTo(2 * 2000 * 3.0, 0.01));
    expect(r.totalCosts, closeTo(2 * 3550, 0.01));
  });

  test('loan is fully repaid within the term with interest', () {
    final r = FeasibilityCalculator.compute(_inputs());
    expect(r.totalRepayment, closeTo(3000 + r.totalInterest, 0.01));
    expect(r.totalInterest, greaterThan(0));
  });

  test('closing cash equals sum of monthly nets', () {
    final r = FeasibilityCalculator.compute(_inputs());
    final sum = r.months.fold(0.0, (a, m) => a + m.net);
    expect(r.months.last.closingCash, closeTo(sum, 0.01));
  });

  test('unprofitable price is flagged as not bankable', () {
    final r = FeasibilityCalculator.compute(_inputs(price: 1.0));
    expect(r.bankable, isFalse);
    expect(r.warnings, isNotEmpty);
  });

  test('no loan means no repayments and no DSCR limit', () {
    final r = FeasibilityCalculator.compute(_inputs(loan: 0));
    expect(r.totalRepayment, 0);
    expect(r.dscr.isInfinite, isTrue);
  });
}
