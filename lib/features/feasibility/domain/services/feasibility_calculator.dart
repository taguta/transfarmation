import 'dart:math';

import '../entities/feasibility_plan.dart';

class CostPhase {
  final String category;
  final double perHa;
  final int startMonth;
  final int months;
  const CostPhase(this.category, this.perHa, this.startMonth, this.months);
}

/// Crop calendar and default economics. Figures are editable starting points,
/// not audited benchmarks.
class CropTemplate {
  final String crop;
  final int cycleMonths;
  final int saleStartMonth;
  final int saleMonths;
  final double yieldKgPerHa;
  final double pricePerKg;
  final double levyPct;
  final List<CostPhase> phases;

  const CropTemplate({
    required this.crop,
    required this.cycleMonths,
    required this.saleStartMonth,
    required this.saleMonths,
    required this.yieldKgPerHa,
    required this.pricePerKg,
    required this.levyPct,
    required this.phases,
  });

  Map<String, double> get costPerHa => {for (final p in phases) p.category: p.perHa};
}

const tobaccoTemplate = CropTemplate(
  crop: 'Tobacco',
  cycleMonths: 12,
  saleStartMonth: 8,
  saleMonths: 4,
  yieldKgPerHa: 2000,
  pricePerKg: 3.0,
  levyPct: 2.0,
  phases: [
    CostPhase('Seedbed & seed', 250, 0, 2),
    CostPhase('Land preparation', 300, 2, 2),
    CostPhase('Fertilizer', 800, 3, 3),
    CostPhase('Chemicals', 350, 4, 4),
    CostPhase('Labour', 900, 3, 6),
    CostPhase('Curing fuel', 700, 6, 3),
    CostPhase('Baling & transport', 250, 8, 2),
  ],
);

const tomatoTemplate = CropTemplate(
  crop: 'Tomatoes',
  cycleMonths: 6,
  saleStartMonth: 3,
  saleMonths: 3,
  yieldKgPerHa: 35000,
  pricePerKg: 0.35,
  levyPct: 0.0,
  phases: [
    CostPhase('Seedlings', 900, 0, 1),
    CostPhase('Land preparation', 400, 0, 1),
    CostPhase('Fertilizer', 1500, 1, 3),
    CostPhase('Chemicals', 1000, 1, 4),
    CostPhase('Irrigation & labour', 1500, 0, 5),
    CostPhase('Crates & transport', 700, 3, 3),
  ],
);

const cropTemplates = {'Tobacco': tobaccoTemplate, 'Tomatoes': tomatoTemplate};

class FeasibilityCalculator {
  static const horizonMonths = 24;
  static const minDscr = 1.25;

  static FeasibilityResult compute(FeasibilityInputs i) {
    final t = cropTemplates[i.crop] ?? tobaccoTemplate;
    final cycles = horizonMonths ~/ t.cycleMonths;
    final cycleRevenue = i.hectares * i.yieldKgPerHa * i.pricePerKg;

    final revenue = List<double>.filled(horizonMonths, 0);
    final costs = List<double>.filled(horizonMonths, 0);

    for (var c = 0; c < cycles; c++) {
      final base = c * t.cycleMonths;
      for (var m = 0; m < t.saleMonths; m++) {
        final idx = base + t.saleStartMonth + m;
        if (idx < horizonMonths) revenue[idx] += cycleRevenue / t.saleMonths;
      }
      for (final p in t.phases) {
        final perHa = i.costPerHa[p.category] ?? p.perHa;
        for (var m = 0; m < p.months; m++) {
          final idx = base + p.startMonth + m;
          if (idx < horizonMonths) costs[idx] += i.hectares * perHa / p.months;
        }
      }
    }

    // Loan: drawn in month 0, interest accrues through grace, then amortises.
    final repay = List<double>.filled(horizonMonths, 0);
    final r = i.annualInterestPct / 100 / 12;
    final grace = i.graceMonths.clamp(0, horizonMonths - 1);
    final payMonths = max(1, min(i.loanTermMonths, horizonMonths) - grace);
    var totalInterest = 0.0;
    if (i.loanAmount > 0) {
      final balanceAfterGrace = i.loanAmount * pow(1 + r, grace);
      final payment = r == 0
          ? balanceAfterGrace / payMonths
          : balanceAfterGrace * r / (1 - pow(1 + r, -payMonths));
      for (var m = 0; m < payMonths && grace + m < horizonMonths; m++) {
        repay[grace + m] = payment;
      }
      totalInterest = payment * payMonths - i.loanAmount;
    }

    var cash = i.ownContribution;
    var minCash = double.infinity;
    var totalLevies = 0.0;
    final months = <MonthlyCashFlow>[];
    for (var m = 0; m < horizonMonths; m++) {
      final levy = revenue[m] * i.levyPct / 100;
      final draw = m == 0 ? i.loanAmount : 0.0;
      cash += revenue[m] + draw - costs[m] - levy - repay[m];
      minCash = min(minCash, cash);
      totalLevies += levy;
      months.add(MonthlyCashFlow(
        index: m,
        month: DateTime(i.startDate.year, i.startDate.month + m),
        revenue: revenue[m],
        costs: costs[m],
        levies: levy,
        loanDraw: draw,
        repayment: repay[m],
        closingCash: cash,
      ));
    }

    final totalRevenue = revenue.fold(0.0, (a, b) => a + b);
    final totalCosts = costs.fold(0.0, (a, b) => a + b);
    final totalRepayment = repay.fold(0.0, (a, b) => a + b);
    final operating = totalRevenue - totalCosts - totalLevies;
    final dscr = totalRepayment == 0 ? double.infinity : operating / totalRepayment;
    final kg = i.hectares * i.yieldKgPerHa * cycles;
    final breakEven = kg == 0
        ? 0.0
        : (totalCosts + totalRepayment) / (kg * (1 - i.levyPct / 100));

    final warnings = <String>[];
    if (minCash < 0) {
      warnings.add('Cash runs out (lowest balance ${minCash.toStringAsFixed(0)}). '
          'Increase the loan or your own contribution.');
    }
    if (dscr < minDscr) {
      warnings.add('Debt cover is ${dscr.toStringAsFixed(2)}; '
          'lenders usually want at least ${minDscr.toStringAsFixed(2)}.');
    }
    if (i.loanAmount > 0 && i.loanTermMonths > horizonMonths) {
      warnings.add('Loan term runs past the 24-month plan; only the first 24 months are shown.');
    }
    if (operating <= 0) warnings.add('Revenue does not cover production costs.');

    return FeasibilityResult(
      months: months,
      totalRevenue: totalRevenue,
      totalCosts: totalCosts,
      totalLevies: totalLevies,
      totalRepayment: totalRepayment,
      totalInterest: totalInterest,
      netProfit: operating - totalRepayment,
      minCash: minCash,
      dscr: dscr,
      breakEvenPricePerKg: breakEven,
      bankable: warnings.isEmpty,
      warnings: warnings,
    );
  }
}
