import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../financing/presentation/providers/loan_providers.dart';
import '../../domain/farmer_statement.dart';
import '../providers/ledger_providers.dart';

final _money = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

/// "What I owe and what I take home": built only from the farmer's own
/// ledger and loans, so it works offline and needs no one else to participate.
class StatementScreen extends ConsumerWidget {
  const StatementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(ledgerEntriesProvider);
    final loans = ref.watch(loanProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('My Statement'),
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load statement: $e')),
        data: (list) {
          final s = FarmerStatement.build(
            entries: list,
            loans: loans.valueOrNull ?? const [],
          );
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _TakeHomeCard(statement: s),
              const SizedBox(height: AppSpacing.lg),
              _line('Money in (sales and other income)', s.income, AppColors.success),
              _line('Money spent (inputs, labour, levies)', s.costs, AppColors.error),
              _line('Still owed on loans', s.loanOutstanding, AppColors.error),
              if (s.costsByCategory.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text('Where the money went', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                for (final c in s.costsByCategory.entries)
                  _line(c.key, c.value, Palette.textPrimary),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text(
                'This is built from the entries in your Farm Ledger and your loans. '
                'Add every sale and cost so the numbers match your real position.',
                style: AppTextStyles.bodySm.copyWith(color: Palette.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => context.push('/ledger'),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Open Farm Ledger'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _line(String label, double amount, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
        Text(
          _money.format(amount),
          style: AppTextStyles.labelLg.copyWith(color: color),
        ),
      ],
    ),
  );
}

class _TakeHomeCard extends StatelessWidget {
  final FarmerStatement statement;
  const _TakeHomeCard({required this.statement});

  @override
  Widget build(BuildContext context) {
    final owing = statement.isOwing;
    final color = owing ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            owing ? 'You currently owe' : 'You would take home',
            style: AppTextStyles.bodyMd.copyWith(color: Palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _money.format(statement.takeHome.abs()),
            style: AppTextStyles.h1.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            owing
                ? 'after counting what you spent and what you still owe on loans.'
                : 'if everything were settled today, after costs and loans.',
            style: AppTextStyles.bodySm.copyWith(color: Palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
