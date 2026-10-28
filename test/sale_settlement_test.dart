import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/ledger/domain/entities/ledger_entry.dart';
import 'package:transfarmation/features/ledger/domain/sale_settlement.dart';

void main() {
  const sale = SaleSettlement(kg: 1000, pricePerKg: 3, levyPct: 2, loanDeduction: 500);

  test('net is sale value minus levy minus loan deduction', () {
    expect(sale.gross, 3000);
    expect(sale.levy, closeTo(60, 1e-9));
    expect(sale.net, closeTo(2440, 1e-9));
  });

  test('deductions larger than the sale are invalid', () {
    const bad = SaleSettlement(kg: 100, pricePerKg: 1, levyPct: 2, loanDeduction: 500);
    expect(bad.isValid, isFalse);
    const empty = SaleSettlement(kg: 0, pricePerKg: 3, levyPct: 2);
    expect(empty.isValid, isFalse);
  });

  test('ledger lines add up to the net received and share a group', () {
    final lines = sale.toEntries(
      groupId: 'g1',
      farmerId: 'f',
      crop: 'Tobacco',
      buyer: 'Acme',
      date: DateTime(2026, 4, 1),
    );
    expect(lines, hasLength(3));
    expect(lines.every((e) => e.groupId == 'g1'), isTrue);
    expect(lines.map((e) => e.id).toSet(), hasLength(3));
    expect(LedgerSummary.of(lines).balance, closeTo(sale.net, 1e-9));
  });

  test('no levy or loan means a single income line', () {
    const plain = SaleSettlement(kg: 10, pricePerKg: 2, levyPct: 0);
    final lines = plain.toEntries(
      groupId: 'g',
      farmerId: 'f',
      crop: 'Maize',
      buyer: '',
      date: DateTime(2026, 4, 1),
    );
    expect(lines, hasLength(1));
    expect(lines.single.type, LedgerType.income);
  });
}
