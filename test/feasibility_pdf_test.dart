import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/feasibility/domain/entities/feasibility_plan.dart';
import 'package:transfarmation/features/feasibility/domain/services/feasibility_calculator.dart';
import 'package:transfarmation/features/feasibility/domain/services/feasibility_pdf.dart';

void main() {
  FeasibilityInputs inputs(String crop) {
    final t = cropTemplates[crop]!;
    return FeasibilityInputs(
      crop: crop,
      hectares: 2,
      yieldKgPerHa: t.yieldKgPerHa,
      pricePerKg: t.pricePerKg,
      costPerHa: t.costPerHa,
      levyPct: t.levyPct,
      loanAmount: 3000,
      annualInterestPct: 18,
      loanTermMonths: 18,
      graceMonths: 8,
      ownContribution: 0,
      startDate: DateTime(2026, 10),
    );
  }

  for (final crop in cropTemplates.keys) {
    test('builds a valid PDF for $crop', () async {
      final i = inputs(crop);
      final bytes = await FeasibilityPdf.build(
        inputs: i,
        result: FeasibilityCalculator.compute(i),
        farmerName: 'Test Farmer',
      );
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
      expect(bytes.length, greaterThan(2000));
    });
  }
}
