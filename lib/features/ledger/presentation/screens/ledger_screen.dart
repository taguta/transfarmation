import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/ledger_entry.dart';
import '../providers/ledger_providers.dart';

final _money = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

const _incomeCategories = ['Crop sales', 'Livestock sales', 'Loan received', 'Other income'];
const _expenseCategories = [
  'Seed', 'Fertilizer', 'Chemicals', 'Labour', 'Fuel & curing',
  'Transport', 'Levies', 'Loan repayment', 'Other expense',
];

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(ledgerEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Farm Ledger'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/ledger/sale'),
            icon: const Icon(Icons.point_of_sale_rounded),
            label: const Text('Record sale'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdd(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add entry'),
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load ledger: $e')),
        data: (list) {
          final s = LedgerSummary.of(list);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(children: [
                Expanded(child: _tile('Income', s.income, AppColors.success)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _tile('Expenses', s.expense, AppColors.error)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              _tile('Balance', s.balance, s.balance >= 0 ? AppColors.primary : AppColors.error),
              const SizedBox(height: AppSpacing.lg),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Text(
                    'No entries yet. Record every sale and expense so lenders can see a verified history.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              for (final e in list)
                Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await ref.read(ledgerRepositoryProvider).deleteEntry(e.id);
                    ref.invalidate(ledgerEntriesProvider);
                  },
                  child: ListTile(
                    leading: Icon(
                      e.type == LedgerType.income
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      color: e.type == LedgerType.income ? AppColors.success : AppColors.error,
                    ),
                    title: Text(e.category),
                    subtitle: Text(
                      [DateFormat.yMMMd().format(e.date), if (e.note.isNotEmpty) e.note].join(' · '),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${e.type == LedgerType.income ? '+' : '-'}${_money.format(e.amount)}',
                          style: AppTextStyles.labelLg,
                        ),
                        Icon(
                          e.isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(String label, double v, Color c) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySm),
        Text(_money.format(v), style: AppTextStyles.h3.copyWith(color: c)),
      ],
    ),
  );

  Future<void> _showAdd(BuildContext context, WidgetRef ref) async {
    var type = LedgerType.expense;
    var category = _expenseCategories.first;
    final amount = TextEditingController();
    final note = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<LedgerType>(
                segments: const [
                  ButtonSegment(value: LedgerType.expense, label: Text('Expense')),
                  ButtonSegment(value: LedgerType.income, label: Text('Income')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setState(() {
                  type = s.first;
                  category = (type == LedgerType.income ? _incomeCategories : _expenseCategories).first;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                key: ValueKey(type),
                initialValue: category,
                items: [
                  for (final c in type == LedgerType.income ? _incomeCategories : _expenseCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => category = v ?? category,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (\$)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(controller: note, decoration: const InputDecoration(labelText: 'Note (optional)')),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final v = double.tryParse(amount.text.trim());
                    if (v == null || v <= 0) return;
                    Navigator.pop(ctx, true);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true) {
      await ref.read(ledgerRepositoryProvider).addEntry(LedgerEntry(
        id: const Uuid().v4(),
        farmerId: ref.read(activeFarmerIdProvider),
        type: type,
        category: category,
        amount: double.parse(amount.text.trim()),
        note: note.text.trim(),
        date: DateTime.now(),
      ));
      ref.invalidate(ledgerEntriesProvider);
    }
  }
}
