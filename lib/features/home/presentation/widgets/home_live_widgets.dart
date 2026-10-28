import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../farm_records/presentation/providers/farm_record_providers.dart';
import '../../../financing/domain/entities/loan.dart';
import '../../../financing/presentation/providers/loan_providers.dart';
import '../../../ledger/domain/entities/ledger_entry.dart';
import '../../../ledger/presentation/providers/ledger_providers.dart';
import '../../../market_prices/domain/entities/commodity.dart';
import '../../../market_prices/presentation/providers/market_price_providers.dart';
import '../../../sync_ui/presentation/providers/sync_providers.dart';
import '../../../weather/presentation/providers/weather_providers.dart';

final _money = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

// ── Stats strip ──────────────────────────────────────────────────────────────

class HomeStats extends ConsumerWidget {
  const HomeStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(farmSummaryProvider);
    final hectares = farm['totalHa'] as double?;
    final owed = ref.watch(outstandingBalanceProvider);
    final ledger = ref.watch(ledgerEntriesProvider).valueOrNull;

    return Row(
      children: [
        _StatCard(
          icon: Icons.landscape_rounded,
          label: 'Farm Size',
          value: hectares == null ? '—' : '${hectares.toStringAsFixed(hectares % 1 == 0 ? 0 : 1)} ha',
          color: AppColors.primary,
          onTap: () => context.push('/farm-records'),
        ),
        const SizedBox(width: AppSpacing.md),
        _StatCard(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Owed on Loans',
          value: _money.format(owed),
          color: AppColors.accent,
          onTap: () => context.go('/financing'),
        ),
        const SizedBox(width: AppSpacing.md),
        _StatCard(
          icon: Icons.menu_book_rounded,
          label: 'Ledger Balance',
          value: ledger == null || ledger.isEmpty
              ? '—'
              : _money.format(LedgerSummary.of(ledger).balance),
          color: AppColors.marketplace,
          onTap: () => context.push('/ledger'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Active loan ──────────────────────────────────────────────────────────────

class ActiveLoanCard extends ConsumerWidget {
  const ActiveLoanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loans = ref.watch(activeLoansProvider);
    if (loans.isEmpty) return _empty(context);
    final Loan loan = loans.first;
    final title = loan.purpose?.isNotEmpty == true
        ? loan.purpose!
        : '${loan.cropType ?? 'Farm'} loan';

    return InkWell(
      onTap: () => context.go('/financing'),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppColors.accent),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.labelLg),
                      Text(
                        loan.lenderName ?? 'Lender pending',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                Text(
                  loan.status.name[0].toUpperCase() + loan.status.name.substring(1),
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _detail('Amount', _money.format(loan.amount)),
                _detail('Repaid', _money.format(loan.amountRepaid)),
                _detail('Outstanding', _money.format(loan.outstanding)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: loan.repaidPercent.toDouble(),
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${(loan.repaidPercent * 100).round()}% repaid',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.request_quote_rounded, color: AppColors.accent),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'No active loans. Build a feasibility plan first, then apply with it.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => context.push('/feasibility'),
          child: const Text('Plan'),
        ),
      ],
    ),
  );

  Widget _detail(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
      Text(value, style: AppTextStyles.labelLg),
    ],
  );
}

// ── Market prices ────────────────────────────────────────────────────────────

class HomeMarketPrices extends ConsumerWidget {
  /// Vertical list for the desktop sidebar, horizontal row otherwise.
  final bool vertical;
  const HomeMarketPrices({super.key, this.vertical = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prices = ref.watch(commoditiesProvider);
    return prices.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _note('Prices unavailable right now.'),
      data: (list) {
        if (list.isEmpty) return _note('Prices appear here once you have synced.');
        final top = list.take(3).toList();
        final tiles = [for (final c in top) _PriceTile(c, vertical: vertical)];
        if (vertical) return Column(children: tiles);
        return Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              Expanded(child: tiles[i]),
              if (i < tiles.length - 1) const SizedBox(width: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }

  Widget _note(String text) => Padding(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Text(text, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
  );
}

class _PriceTile extends StatelessWidget {
  final Commodity c;
  final bool vertical;
  const _PriceTile(this.c, {required this.vertical});

  @override
  Widget build(BuildContext context) {
    final color = c.isUp ? AppColors.success : AppColors.error;
    final pct = '${c.isUp ? '+' : ''}${c.changePercent.toStringAsFixed(1)}%';
    return Padding(
      padding: EdgeInsets.only(bottom: vertical ? AppSpacing.md : 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
            Text(
              '\$${c.currentPrice.toStringAsFixed(2)}',
              style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary),
            ),
            Text(c.unit, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(c.isUp ? Icons.trending_up : Icons.trending_down, size: 14, color: color),
                const SizedBox(width: 2),
                Text(pct, style: AppTextStyles.caption.copyWith(color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weather advisory ─────────────────────────────────────────────────────────

class HomeAdvisoryCard extends ConsumerWidget {
  const HomeAdvisoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(weatherAlertsProvider).valueOrNull ?? const [];
    final alert = alerts.isEmpty ? null : alerts.first;
    final title = alert?.title ?? 'No weather alerts';
    final body = alert == null
        ? 'Check the forecast before planning field work.'
        : (alert.actionAdvice.isNotEmpty ? alert.actionAdvice : alert.description);

    return InkWell(
      onTap: () => context.push('/weather'),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ── Sync status ──────────────────────────────────────────────────────────────

class HomeSyncBanner extends ConsumerWidget {
  const HomeSyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(syncItemsProvider).valueOrNull?.length ?? 0;
    final synced = pending == 0;
    final color = synced ? AppColors.success : AppColors.warning;

    return InkWell(
      onTap: () => context.push('/profile/sync'),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
              color: color,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                synced
                    ? 'All data synced'
                    : '$pending ${pending == 1 ? 'change' : 'changes'} waiting to sync',
                style: AppTextStyles.labelMd.copyWith(color: color),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
