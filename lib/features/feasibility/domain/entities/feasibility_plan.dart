/// Farmer-editable assumptions behind a feasibility plan.
class FeasibilityInputs {
  final String crop;
  final double hectares;
  final double yieldKgPerHa;
  final double pricePerKg;

  /// Cost per hectare for one production cycle, keyed by category.
  final Map<String, double> costPerHa;

  /// Statutory levies as a percentage of revenue (e.g. TIMB levy).
  final double levyPct;
  final double loanAmount;
  final double annualInterestPct;
  final int loanTermMonths;
  final int graceMonths;
  final double ownContribution;
  final DateTime startDate;

  const FeasibilityInputs({
    required this.crop,
    required this.hectares,
    required this.yieldKgPerHa,
    required this.pricePerKg,
    required this.costPerHa,
    required this.levyPct,
    required this.loanAmount,
    required this.annualInterestPct,
    required this.loanTermMonths,
    required this.graceMonths,
    required this.ownContribution,
    required this.startDate,
  });

  Map<String, dynamic> toJson() => {
    'crop': crop,
    'hectares': hectares,
    'yieldKgPerHa': yieldKgPerHa,
    'pricePerKg': pricePerKg,
    'costPerHa': costPerHa,
    'levyPct': levyPct,
    'loanAmount': loanAmount,
    'annualInterestPct': annualInterestPct,
    'loanTermMonths': loanTermMonths,
    'graceMonths': graceMonths,
    'ownContribution': ownContribution,
    'startDate': startDate.toIso8601String(),
  };

  factory FeasibilityInputs.fromJson(Map<String, dynamic> j) => FeasibilityInputs(
    crop: j['crop'] as String,
    hectares: (j['hectares'] as num).toDouble(),
    yieldKgPerHa: (j['yieldKgPerHa'] as num).toDouble(),
    pricePerKg: (j['pricePerKg'] as num).toDouble(),
    costPerHa: (j['costPerHa'] as Map).map(
      (k, v) => MapEntry(k as String, (v as num).toDouble()),
    ),
    levyPct: (j['levyPct'] as num).toDouble(),
    loanAmount: (j['loanAmount'] as num).toDouble(),
    annualInterestPct: (j['annualInterestPct'] as num).toDouble(),
    loanTermMonths: j['loanTermMonths'] as int,
    graceMonths: j['graceMonths'] as int,
    ownContribution: (j['ownContribution'] as num).toDouble(),
    startDate: DateTime.parse(j['startDate'] as String),
  );
}

class MonthlyCashFlow {
  final int index;
  final DateTime month;
  final double revenue;
  final double costs;
  final double levies;
  final double loanDraw;
  final double repayment;
  final double closingCash;

  const MonthlyCashFlow({
    required this.index,
    required this.month,
    required this.revenue,
    required this.costs,
    required this.levies,
    required this.loanDraw,
    required this.repayment,
    required this.closingCash,
  });

  double get net => revenue + loanDraw - costs - levies - repayment;
}

class FeasibilityResult {
  final List<MonthlyCashFlow> months;
  final double totalRevenue;
  final double totalCosts;
  final double totalLevies;
  final double totalRepayment;
  final double totalInterest;
  final double netProfit;
  final double minCash;
  final double dscr;
  final double breakEvenPricePerKg;
  final bool bankable;
  final List<String> warnings;

  const FeasibilityResult({
    required this.months,
    required this.totalRevenue,
    required this.totalCosts,
    required this.totalLevies,
    required this.totalRepayment,
    required this.totalInterest,
    required this.netProfit,
    required this.minCash,
    required this.dscr,
    required this.breakEvenPricePerKg,
    required this.bankable,
    required this.warnings,
  });
}

class FeasibilityPlan {
  final String id;
  final String farmerId;
  final FeasibilityInputs inputs;
  final DateTime createdAt;
  final bool isSynced;

  const FeasibilityPlan({
    required this.id,
    required this.farmerId,
    required this.inputs,
    required this.createdAt,
    this.isSynced = false,
  });
}
