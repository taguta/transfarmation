import 'entities/ledger_entry.dart';

/// What a farmer actually receives from a sale once statutory levies and any
/// loan repayment taken by the buyer are deducted, shown line by line.
class SaleSettlement {
  final double kg;
  final double pricePerKg;
  final double levyPct;
  final double loanDeduction;

  const SaleSettlement({
    required this.kg,
    required this.pricePerKg,
    required this.levyPct,
    this.loanDeduction = 0,
  });

  double get gross => kg * pricePerKg;
  double get levy => gross * levyPct / 100;
  double get net => gross - levy - loanDeduction;

  /// The levy plus the loan deduction can never exceed what was earned.
  bool get isValid =>
      kg > 0 && pricePerKg > 0 && levyPct >= 0 && levyPct < 100 &&
      loanDeduction >= 0 && levy + loanDeduction <= gross;

  /// Ledger lines for this sale, tied together by [groupId] so they are
  /// kept and removed as one.
  List<LedgerEntry> toEntries({
    required String groupId,
    required String farmerId,
    required String crop,
    required String buyer,
    required DateTime date,
  }) {
    final who = buyer.isEmpty ? '' : ' to $buyer';
    final sold = '${kg.toStringAsFixed(kg % 1 == 0 ? 0 : 1)} kg of $crop$who';
    LedgerEntry line(String suffix, LedgerType type, String category, double amount, String note) =>
        LedgerEntry(
          id: '${groupId}_$suffix',
          farmerId: farmerId,
          type: type,
          category: category,
          amount: amount,
          note: note,
          date: date,
          groupId: groupId,
        );

    return [
      line('gross', LedgerType.income, 'Crop sales', gross, 'Sold $sold'),
      if (levy > 0)
        line('levy', LedgerType.expense, 'Levies', levy,
            '${levyPct.toStringAsFixed(levyPct % 1 == 0 ? 0 : 1)}% statutory levy on sale of $sold'),
      if (loanDeduction > 0)
        line('loan', LedgerType.expense, 'Loan repayment', loanDeduction,
            'Deducted by buyer on sale of $sold'),
    ];
  }
}
