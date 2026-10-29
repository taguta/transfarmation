import '../../financing/domain/entities/loan.dart';
import 'entities/ledger_entry.dart';

/// Plain-language picture of what a farmer has earned, spent and still owes,
/// and what they would take home if everything were settled today.
class FarmerStatement {
  final double income;
  final double costs;
  final double loanOutstanding;
  final Map<String, double> costsByCategory;

  const FarmerStatement({
    required this.income,
    required this.costs,
    required this.loanOutstanding,
    required this.costsByCategory,
  });

  /// Ledger balance minus what is still owed on active loans. Can be negative.
  double get takeHome => income - costs - loanOutstanding;

  bool get isOwing => takeHome < 0;

  factory FarmerStatement.build({
    required Iterable<LedgerEntry> entries,
    required Iterable<Loan> loans,
  }) {
    var income = 0.0, costs = 0.0;
    final byCategory = <String, double>{};
    for (final e in entries) {
      if (e.type == LedgerType.income) {
        income += e.amount;
      } else {
        costs += e.amount;
        byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
      }
    }
    final outstanding = loans
        .where((l) =>
            l.status == LoanStatus.approved || l.status == LoanStatus.disbursed)
        .fold<double>(0, (sum, l) => sum + (l.outstanding < 0 ? 0 : l.outstanding));
    return FarmerStatement(
      income: income,
      costs: costs,
      loanOutstanding: outstanding,
      costsByCategory: Map.fromEntries(
        byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      ),
    );
  }
}
