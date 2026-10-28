enum LedgerType { income, expense }

class LedgerEntry {
  final String id;
  final String farmerId;
  final LedgerType type;
  final String category;
  final double amount;
  final String note;
  final DateTime date;
  final bool isSynced;

  /// Entries created together (e.g. one sale) share a group and are removed together.
  final String? groupId;

  const LedgerEntry({
    required this.id,
    required this.farmerId,
    required this.type,
    required this.category,
    required this.amount,
    required this.note,
    required this.date,
    this.isSynced = false,
    this.groupId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'farmerId': farmerId,
    'type': type.name,
    'category': category,
    'amount': amount,
    'note': note,
    'date': date.toIso8601String(),
    'groupId': groupId,
  };

  factory LedgerEntry.fromMap(Map<String, Object?> r) => LedgerEntry(
    id: r['id'] as String,
    farmerId: r['farmerId'] as String,
    type: r['type'] == 'income' ? LedgerType.income : LedgerType.expense,
    category: r['category'] as String? ?? '',
    amount: (r['amount'] as num).toDouble(),
    note: r['note'] as String? ?? '',
    date: DateTime.parse(r['date'] as String),
    isSynced: (r['isSynced'] as int? ?? 0) == 1,
    groupId: r['groupId'] as String?,
  );
}

class LedgerSummary {
  final double income;
  final double expense;
  const LedgerSummary(this.income, this.expense);
  double get balance => income - expense;

  factory LedgerSummary.of(Iterable<LedgerEntry> entries) {
    var i = 0.0, e = 0.0;
    for (final x in entries) {
      if (x.type == LedgerType.income) {
        i += x.amount;
      } else {
        e += x.amount;
      }
    }
    return LedgerSummary(i, e);
  }
}
