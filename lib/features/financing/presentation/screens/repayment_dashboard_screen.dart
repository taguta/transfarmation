import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/loan.dart';

class RepaymentDashboardScreen extends StatelessWidget {
  const RepaymentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // MVP mock data for the active loan
    final loan = Loan(
      id: 'loan-001',
      farmerId: 'farmer-001',
      amount: 1200,
      status: LoanStatus.approved,
      createdAt: DateTime(2026, 1, 15),
      isSynced: true,
      farmName: 'Moyo Family Farm',
      cropType: 'Maize',
      purpose: 'Input Purchase',
      repaymentPeriod: '6 months',
      farmSize: 12,
      amountRepaid: 480,
      lenderName: 'AgriFinance ZW',
    );

    final schedule = [
      _ScheduleItem('Jan 2026', 200, true),
      _ScheduleItem('Feb 2026', 200, true),
      _ScheduleItem('Mar 2026', 80, true),
      _ScheduleItem('Apr 2026', 224, false),
      _ScheduleItem('May 2026', 224, false),
      _ScheduleItem('Jun 2026', 224, false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repayment Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan summary card
            _buildLoanSummary(loan),
            const SizedBox(height: AppSpacing.xxl),

            // Progress ring
            _buildRepaymentProgress(loan),
            const SizedBox(height: AppSpacing.xxl),

            // Quick pay button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentSheet(context),
                icon: const Icon(Icons.payment_rounded),
                label: const Text('Make Payment'),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Payment breakdown
            _buildPaymentBreakdown(loan),
            const SizedBox(height: AppSpacing.xxl),

            // Schedule
            Text(
              'Repayment Schedule',
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            ...schedule.map((s) => _buildScheduleRow(s)),
            const SizedBox(height: AppSpacing.xxl),

            // Payment history
            Text(
              'Payment History',
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPaymentHistory(),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanSummary(Loan loan) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loan.purpose ?? 'Loan',
                style: AppTextStyles.labelLg.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Active',
                  style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '\$${loan.outstanding.toStringAsFixed(0)}',
            style: AppTextStyles.displaySm.copyWith(color: Colors.white),
          ),
          Text(
            'remaining of \$${loan.amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMd.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: loan.repaidPercent,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: AppColors.accentLight,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(loan.repaidPercent * 100).toInt()}% paid',
                style: AppTextStyles.labelSm.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                loan.lenderName ?? '',
                style: AppTextStyles.labelSm.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentProgress(Loan loan) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Total Paid',
            value: '\$${loan.amountRepaid.toStringAsFixed(0)}',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MetricCard(
            label: 'Next Payment',
            value: '\$224',
            icon: Icons.calendar_today_rounded,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MetricCard(
            label: 'Due Date',
            value: 'Apr 15',
            icon: Icons.access_time_rounded,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdown(Loan loan) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _breakdownRow('Principal', '\$1,200.00'),
          _breakdownRow('Interest (12%)', '\$144.00'),
          const Divider(height: AppSpacing.xxl),
          _breakdownRow('Total Repayable', '\$1,344.00', isBold: true),
          _breakdownRow('Amount Paid', '-\$480.00', color: AppColors.success),
          const Divider(height: AppSpacing.xxl),
          _breakdownRow('Outstanding', '\$864.00', isBold: true, color: AppColors.accent),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.labelLg.copyWith(
                    color: AppColors.textPrimary,
                  )
                : AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
          Text(
            value,
            style: isBold
                ? AppTextStyles.labelLg.copyWith(
                    color: color ?? AppColors.textPrimary,
                  )
                : AppTextStyles.bodyMd.copyWith(
                    color: color ?? AppColors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(_ScheduleItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: item.isPaid
            ? AppColors.successSurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: item.isPaid
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            item.isPaid ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: item.isPaid ? AppColors.success : AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              item.month,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.textPrimary,
                decoration: item.isPaid ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            '\$${item.amount.toStringAsFixed(0)}',
            style: AppTextStyles.labelLg.copyWith(
              color: item.isPaid ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    final payments = [
      ('Mar 10, 2026', 80.0, 'EcoCash'),
      ('Feb 15, 2026', 200.0, 'Bank Transfer'),
      ('Jan 20, 2026', 200.0, 'EcoCash'),
    ];

    return Column(
      children: payments.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment received',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${p.$1} · ${p.$3}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${p.$2.toStringAsFixed(0)}',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Make a Payment',
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (USD)',
                prefixIcon: Icon(Icons.attach_money_rounded),
                hintText: '224',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              value: 'EcoCash',
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'EcoCash', child: Text('EcoCash')),
                DropdownMenuItem(value: 'OneMoney', child: Text('OneMoney')),
                DropdownMenuItem(
                    value: 'Bank Transfer', child: Text('Bank Transfer')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Confirm Payment'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem {
  final String month;
  final double amount;
  final bool isPaid;
  _ScheduleItem(this.month, this.amount, this.isPaid);
}
