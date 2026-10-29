import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/financing/domain/entities/loan.dart';
import 'package:transfarmation/features/financing/domain/services/loan_file_pdf.dart';
import 'package:transfarmation/features/ledger/domain/entities/ledger_entry.dart';
import 'package:transfarmation/features/ledger/domain/farmer_statement.dart';

void main() {
  final loan = Loan(
    id: 'loan-1', farmerId: 'f', amount: 1500, status: LoanStatus.pending,
    createdAt: DateTime(2026, 10, 1), isSynced: true, farmName: 'Green Valley',
    cropType: 'Tobacco', farmSize: 2, purpose: 'Inputs',
    planSummary: {'Net profit': 900},
  );

  test('builds a valid PDF with records and a named recipient', () async {
    final entries = [
      LedgerEntry(
        id: 'a', farmerId: 'f', type: LedgerType.income, category: 'Crop sales',
        amount: 800, note: '', date: DateTime(2026, 8, 1),
      ),
      LedgerEntry(
        id: 'b', farmerId: 'f', type: LedgerType.expense, category: 'Seed',
        amount: 200, note: '', date: DateTime(2026, 9, 1),
      ),
    ];
    final bytes = await LoanFilePdf.build(
      loan: loan,
      statement: FarmerStatement.build(entries: entries, loans: [loan]),
      entries: entries,
      farmerName: 'Test Farmer',
      sharedWith: 'Example Bank',
    );
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(1500));
  });

  test('still builds when there are no ledger entries', () async {
    final bytes = await LoanFilePdf.build(
      loan: loan,
      statement: FarmerStatement.build(entries: [], loans: []),
      entries: [],
    );
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
  });
}
