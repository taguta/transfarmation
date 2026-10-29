import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/feasibility_plan.dart';
import '../../domain/services/feasibility_calculator.dart';
import '../../domain/services/feasibility_pdf.dart';
import '../providers/feasibility_providers.dart';

final _money = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

class FeasibilityScreen extends ConsumerStatefulWidget {
  const FeasibilityScreen({super.key});

  @override
  ConsumerState<FeasibilityScreen> createState() => _FeasibilityScreenState();
}

class _FeasibilityScreenState extends ConsumerState<FeasibilityScreen> {
  String _crop = 'Tobacco';
  final _hectares = TextEditingController(text: '1');
  final _yield = TextEditingController();
  final _price = TextEditingController();
  final _loan = TextEditingController(text: '3000');
  final _rate = TextEditingController(text: '18');
  final _term = TextEditingController(text: '18');
  final _grace = TextEditingController(text: '8');
  final _own = TextEditingController(text: '0');
  final Map<String, TextEditingController> _costs = {};

  @override
  void initState() {
    super.initState();
    _applyTemplate(_crop);
  }

  @override
  void dispose() {
    for (final c in [_hectares, _yield, _price, _loan, _rate, _term, _grace, _own, ..._costs.values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyTemplate(String crop) {
    final t = cropTemplates[crop]!;
    _crop = crop;
    _yield.text = t.yieldKgPerHa.toStringAsFixed(0);
    _price.text = t.pricePerKg.toString();
    for (final c in _costs.values) {
      c.dispose();
    }
    _costs
      ..clear()
      ..addEntries(t.costPerHa.entries.map(
        (e) => MapEntry(e.key, TextEditingController(text: e.value.toStringAsFixed(0))),
      ));
  }

  double _n(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  FeasibilityInputs _inputs() => FeasibilityInputs(
    crop: _crop,
    hectares: _n(_hectares),
    yieldKgPerHa: _n(_yield),
    pricePerKg: _n(_price),
    costPerHa: {for (final e in _costs.entries) e.key: _n(e.value)},
    levyPct: cropTemplates[_crop]!.levyPct,
    loanAmount: _n(_loan),
    annualInterestPct: _n(_rate),
    loanTermMonths: _n(_term).round(),
    graceMonths: _n(_grace).round(),
    ownContribution: _n(_own),
    startDate: DateTime(DateTime.now().year, DateTime.now().month),
  );

  Future<void> _save(FeasibilityInputs inputs) async {
    final plan = FeasibilityPlan(
      id: const Uuid().v4(),
      farmerId: ref.read(activeFarmerIdProvider),
      inputs: inputs,
      createdAt: DateTime.now(),
    );
    await ref.read(feasibilityRepositoryProvider).savePlan(plan);
    ref.invalidate(feasibilityPlansProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan saved. It will sync when you are online.')),
    );
  }

  Future<void> _share(FeasibilityInputs inputs, FeasibilityResult result) async {
    try {
      final name = ref.read(authStateProvider).valueOrNull?.displayName ?? '';
      final bytes = await FeasibilityPdf.build(
        inputs: inputs,
        result: result,
        farmerName: name,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'feasibility-plan-${inputs.crop.toLowerCase()}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create the PDF: $e')),
      );
    }
  }

  void _load(FeasibilityInputs i) {
    setState(() {
      _applyTemplate(i.crop);
      _hectares.text = i.hectares.toString();
      _yield.text = i.yieldKgPerHa.toString();
      _price.text = i.pricePerKg.toString();
      _loan.text = i.loanAmount.toString();
      _rate.text = i.annualInterestPct.toString();
      _term.text = i.loanTermMonths.toString();
      _grace.text = i.graceMonths.toString();
      _own.text = i.ownContribution.toString();
      for (final e in i.costPerHa.entries) {
        _costs[e.key]?.text = e.value.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputs = _inputs();
    final result = FeasibilityCalculator.compute(inputs);
    final plans = ref.watch(feasibilityPlansProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Bankable Feasibility Plan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Edit the numbers below. The 24-month plan updates as you type and works offline.',
            style: AppTextStyles.bodyMd.copyWith(color: Palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _section('Crop'),
          SegmentedButton<String>(
            segments: [for (final c in cropTemplates.keys) ButtonSegment(value: c, label: Text(c))],
            selected: {_crop},
            onSelectionChanged: (s) => setState(() => _applyTemplate(s.first)),
          ),
          const SizedBox(height: AppSpacing.md),
          _row([_field(_hectares, 'Hectares'), _field(_yield, 'Yield (kg/ha)')]),
          _row([_field(_price, 'Price (\$/kg)'), _field(_own, 'Own cash (\$)')]),
          _section('Production cost per hectare (\$ per cycle)'),
          for (final e in _costs.entries) _field(e.value, e.key),
          _section('Loan'),
          _row([_field(_loan, 'Amount (\$)'), _field(_rate, 'Interest (% p.a.)')]),
          _row([_field(_term, 'Term (months)'), _field(_grace, 'Grace (months)')]),
          const SizedBox(height: AppSpacing.lg),
          _Summary(result: result),
          const SizedBox(height: AppSpacing.lg),
          _section('Cash balance over 24 months'),
          SizedBox(height: 200, child: _CashChart(result: result)),
          const SizedBox(height: AppSpacing.lg),
          _MonthTable(result: result),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: inputs.hectares > 0 ? () => _save(inputs) : null,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save plan'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: inputs.hectares > 0 ? () => _share(inputs, result) : null,
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('Share PDF with a lender'),
          ),
          if (plans.isNotEmpty) ...[
            _section('Saved plans'),
            for (final p in plans)
              Card(
                child: ListTile(
                  title: Text('${p.inputs.crop} · ${p.inputs.hectares} ha'),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(p.createdAt)} · '
                    '${p.isSynced ? "Synced" : "Waiting to sync"}',
                  ),
                  onTap: () => _load(p.inputs),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () async {
                      await ref.read(feasibilityRepositoryProvider).deletePlan(p.id);
                      ref.invalidate(feasibilityPlansProvider);
                    },
                  ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
    child: Text(t, style: AppTextStyles.h4.copyWith(color: Palette.textPrimary)),
  );

  Widget _row(List<Widget> children) => Row(
    children: [
      for (final c in children) Expanded(child: c),
    ],
  );

  Widget _field(TextEditingController c, String label) => Padding(
    padding: const EdgeInsets.all(AppSpacing.xs),
    child: TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => setState(() {}),
    ),
  );
}

class _Summary extends StatelessWidget {
  final FeasibilityResult result;
  const _Summary({required this.result});

  @override
  Widget build(BuildContext context) {
    final ok = result.bankable;
    final color = ok ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(ok ? Icons.verified_rounded : Icons.warning_amber_rounded, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(ok ? 'Looks bankable' : 'Needs attention', style: AppTextStyles.h3),
          ]),
          const SizedBox(height: AppSpacing.md),
          _line('Revenue (24 months)', _money.format(result.totalRevenue)),
          _line('Production costs', _money.format(result.totalCosts)),
          _line('Statutory levies', _money.format(result.totalLevies)),
          _line('Loan repayments', _money.format(result.totalRepayment)),
          _line('  of which interest', _money.format(result.totalInterest)),
          _line('Net profit', _money.format(result.netProfit)),
          _line('Debt service cover', result.dscr.isFinite ? result.dscr.toStringAsFixed(2) : 'No loan'),
          _line('Break-even price', '\$${result.breakEvenPricePerKg.toStringAsFixed(2)}/kg'),
          for (final w in result.warnings)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text('• $w', style: AppTextStyles.bodySm),
            ),
        ],
      ),
    );
  }

  Widget _line(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(a, style: AppTextStyles.bodyMd), Text(b, style: AppTextStyles.labelLg)],
    ),
  );
}

class _CashChart extends StatelessWidget {
  final FeasibilityResult result;
  const _CashChart({required this.result});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (v, _) => Text(
                NumberFormat.compactCurrency(symbol: '\$').format(v),
                style: AppTextStyles.caption,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= result.months.length) return const SizedBox();
                return Text(DateFormat.MMM().format(result.months[i].month), style: AppTextStyles.caption);
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (final m in result.months) FlSpot(m.index.toDouble(), m.closingCash)],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}

class _MonthTable extends StatelessWidget {
  final FeasibilityResult result;
  const _MonthTable({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Month')),
          DataColumn(label: Text('In'), numeric: true),
          DataColumn(label: Text('Out'), numeric: true),
          DataColumn(label: Text('Loan'), numeric: true),
          DataColumn(label: Text('Cash'), numeric: true),
        ],
        rows: [
          for (final m in result.months)
            DataRow(cells: [
              DataCell(Text(DateFormat('MMM yy').format(m.month))),
              DataCell(Text(_money.format(m.revenue))),
              DataCell(Text(_money.format(m.costs + m.levies))),
              DataCell(Text(_money.format(m.loanDraw - m.repayment))),
              DataCell(Text(
                _money.format(m.closingCash),
                style: TextStyle(color: m.closingCash < 0 ? AppColors.error : null),
              )),
            ]),
        ],
      ),
    );
  }
}
