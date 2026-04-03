import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class LoanStatusScreen extends StatelessWidget {
  const LoanStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Financing',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track your loans and repayments',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: () => context.go('/financing/apply'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Apply'),
                  ),
                ],
              ),
            ),

            // Portfolio summary
            _buildPortfolioSummary(),
            const SizedBox(height: AppSpacing.md),

            // Quick action row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/financing/offers'),
                      icon: const Icon(Icons.compare_arrows, size: 18),
                      label: const Text('Compare Offers'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/financing/repayments'),
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('Repayments'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Filter chips
            _buildFilterChips(),
            const SizedBox(height: AppSpacing.md),

            // Loan list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: const [
                  _LoanListItem(
                    title: 'Maize Input Loan',
                    lender: 'AgriFinance ZW',
                    amount: 1200,
                    status: 'approved',
                    date: 'Jan 2026',
                    repaidPercent: 0.4,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _LoanListItem(
                    title: 'Irrigation Equipment',
                    lender: 'FarmFund Africa',
                    amount: 3500,
                    status: 'pending',
                    date: 'Mar 2026',
                    repaidPercent: 0.0,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _LoanListItem(
                    title: 'Soya Seed Purchase',
                    lender: 'ZimAgri Micro',
                    amount: 800,
                    status: 'approved',
                    date: 'Nov 2025',
                    repaidPercent: 1.0,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _LoanListItem(
                    title: 'Tractor Hire',
                    lender: 'AgriFinance ZW',
                    amount: 450,
                    status: 'rejected',
                    date: 'Oct 2025',
                    repaidPercent: 0.0,
                  ),
                  SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PortfolioStat(label: 'Total Borrowed', value: '\$5,950'),
              _PortfolioStat(label: 'Outstanding', value: '\$2,400'),
              _PortfolioStat(label: 'Credit Score', value: '72/100'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: AppColors.accentLight,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '60% of total loans repaid',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _FilterChip(label: 'All', selected: true),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(label: 'Active', selected: false),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(label: 'Pending', selected: false),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(label: 'Completed', selected: false),
        ],
      ),
    );
  }
}

class _PortfolioStat extends StatelessWidget {
  final String label;
  final String value;

  const _PortfolioStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h3.copyWith(color: Colors.white)),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      selectedColor: AppColors.primarySurface,
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMd.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

class _LoanListItem extends StatelessWidget {
  final String title;
  final String lender;
  final double amount;
  final String status;
  final String date;
  final double repaidPercent;

  const _LoanListItem({
    required this.title,
    required this.lender,
    required this.amount,
    required this.status,
    required this.date,
    required this.repaidPercent,
  });

  Color get _statusColor => switch (status) {
    'approved' => AppColors.loanApproved,
    'pending' => AppColors.loanPending,
    'rejected' => AppColors.loanRejected,
    _ => AppColors.loanDraft,
  };

  String get _statusLabel => switch (status) {
    'approved' => repaidPercent >= 1.0 ? 'Completed' : 'Active',
    'pending' => 'Pending',
    'rejected' => 'Rejected',
    _ => 'Draft',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          status == 'approved' && repaidPercent < 1.0
              ? () => context.go('/financing/repayments')
              : null,
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
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: _statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        lender,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _statusLabel,
                    style: AppTextStyles.labelSm.copyWith(color: _statusColor),
                  ),
                ),
              ],
            ),
            if (status == 'approved' && repaidPercent < 1.0) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${(repaidPercent * 100).toInt()}% repaid',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: repaidPercent,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                  minHeight: 4,
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    date,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
