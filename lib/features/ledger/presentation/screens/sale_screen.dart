import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feasibility/domain/services/feasibility_calculator.dart';
import '../../domain/sale_settlement.dart';
import '../providers/ledger_providers.dart';

final _money = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

const _crops = ['Tobacco', 'Tomatoes', 'Maize', 'Other'];

class SaleScreen extends ConsumerStatefulWidget {
  const SaleScreen({super.key});

  @override
  ConsumerState<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends ConsumerState<SaleScreen> {
  String _crop = 'Tobacco';
  final _kg = TextEditingController();
  final _price = TextEditingController();
  final _buyer = TextEditingController();
  final _levy = TextEditingController();
  final _loan = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _applyCrop(_crop);
  }

  @override
  void dispose() {
    for (final c in [_kg, _price, _buyer, _levy, _loan]) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyCrop(String crop) {
    _crop = crop;
    final t = cropTemplates[crop];
    _price.text = t == null ? '' : t.pricePerKg.toString();
    _levy.text = (t?.levyPct ?? 0).toString();
  }

  double _n(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  SaleSettlement get _settlement => SaleSettlement(
    kg: _n(_kg),
    pricePerKg: _n(_price),
    levyPct: _n(_levy),
    loanDeduction: _n(_loan),
  );

  Future<void> _save() async {
    final s = _settlement;
    if (!s.isValid) return;
    setState(() => _saving = true);
    try {
      final entries = s.toEntries(
        groupId: const Uuid().v4(),
        farmerId: ref.read(activeFarmerIdProvider),
        crop: _crop,
        buyer: _buyer.text.trim(),
        date: DateTime.now(),
      );
      await ref.read(ledgerRepositoryProvider).addEntries(entries);
      ref.invalidate(ledgerEntriesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale recorded. You receive ${_money.format(s.net)}.')),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save the sale: $e')),
        );
      }
    }
  }

  Widget _field(TextEditingController c, String label, {bool number = true}) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: TextField(
      controller: c,
      keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => setState(() {}),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = _settlement;
    final hasInput = s.kg > 0 && s.pricePerKg > 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/ledger'),
        ),
        title: const Text('Record a Sale'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SegmentedButton<String>(
            segments: [for (final c in _crops) ButtonSegment(value: c, label: Text(c))],
            selected: {_crop},
            onSelectionChanged: (v) => setState(() => _applyCrop(v.first)),
          ),
          const SizedBox(height: AppSpacing.lg),
          _field(_buyer, 'Buyer (optional)', number: false),
          _field(_kg, 'Quantity sold (kg)'),
          _field(_price, 'Price paid (\$ per kg)'),
          _field(_levy, 'Statutory levy (% of sale)'),
          Text(
            'The levy rate is a starting estimate. Check the rate on your sale '
            'slip or with the buyer or TIMB and change it if it differs.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          _field(_loan, 'Loan repayment taken by the buyer (\$)'),
          const SizedBox(height: AppSpacing.md),
          _Statement(settlement: s, show: hasInput),
          if (hasInput && !s.isValid)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'The levy and loan deduction are more than the sale is worth. Check the numbers.',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: s.isValid && !_saving ? _save : null,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save sale to ledger'),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _Statement extends StatelessWidget {
  final SaleSettlement settlement;
  final bool show;
  const _Statement({required this.settlement, required this.show});

  Widget _line(String a, String b, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: bold ? AppTextStyles.labelLg : AppTextStyles.bodyMd),
        Text(b, style: (bold ? AppTextStyles.h4 : AppTextStyles.labelLg).copyWith(color: color)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Text(
        'Enter the quantity and price to see exactly what you will receive.',
        style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
      );
    }
    final s = settlement;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settlement statement', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.sm),
          _line('Sale value', _money.format(s.gross)),
          _line('Statutory levy (${s.levyPct}%)', '- ${_money.format(s.levy)}'),
          if (s.loanDeduction > 0) _line('Loan repayment', '- ${_money.format(s.loanDeduction)}'),
          const Divider(),
          _line('You receive', _money.format(s.net), bold: true, color: AppColors.primary),
        ],
      ),
    );
  }
}
