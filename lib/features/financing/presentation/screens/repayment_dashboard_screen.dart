import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repayment_plan.dart';
import '../providers/loan_providers.dart';

final _money = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
final _day = DateFormat('d MMM yyyy');

class RepaymentDashboardScreen extends ConsumerWidget {
  const RepaymentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(loanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repayment Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: loanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (loans) {
          final activeLoans = loans.where(
            (l) => l.status == LoanStatus.approved || l.status == LoanStatus.disbursed,
          ).toList();

          if (activeLoans.isEmpty) {
            return Center(
              child: Text(
                'No active loans found.',
                style: AppTextStyles.bodyMd.copyWith(color: Palette.textTertiary),
              ),
            );
          }

          final loan = activeLoans.first;
          final payments = ref.watch(loanPaymentsProvider(loan.id)).valueOrNull ?? const <LoanPayment>[];
          final plan = RepaymentPlan.forLoan(loan, payments);

          final summaryColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan summary card
              _buildLoanSummary(loan, plan),
              const SizedBox(height: AppSpacing.xxl),

              // Progress ring
              _buildRepaymentProgress(plan),
              const SizedBox(height: AppSpacing.xxl),

              // Quick pay button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: plan.isPaidOff ? null : () => _showPaymentSheet(context, loan, plan),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Record a payment'),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Payment breakdown
              _buildPaymentBreakdown(plan),
            ],
          );

          final historyColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Schedule
              Text(
                'Repayment Schedule',
                style: AppTextStyles.h3.copyWith(color: Palette.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'An even split of the amount borrowed. Interest and fees are set by your lender and are not included, so check their statement for exact figures.',
                style: AppTextStyles.caption.copyWith(color: Palette.textTertiary),
              ),
              const SizedBox(height: AppSpacing.md),
              ...plan.instalments.map(_buildScheduleRow),
              const SizedBox(height: AppSpacing.xxl),

              // Payment history
              Text(
                'Payment History',
                style: AppTextStyles.h3.copyWith(color: Palette.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildPaymentHistory(payments),
            ],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: context.isTabletOrDesktop && context.screenWidth >= 1000
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: summaryColumn),
                      const SizedBox(width: AppSpacing.xxl),
                      Expanded(child: historyColumn),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      summaryColumn,
                      const SizedBox(height: AppSpacing.xxl),
                      historyColumn,
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildLoanSummary(Loan loan, RepaymentPlan plan) {
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
                  plan.isPaidOff ? 'Paid off' : 'Active',
                  style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _money.format(plan.outstanding),
            style: AppTextStyles.displaySm.copyWith(color: Colors.white),
          ),
          Text(
            'remaining of ${_money.format(loan.amount)}',
            style: AppTextStyles.bodyMd.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: loan.amount > 0 ? (plan.totalPaid / loan.amount).clamp(0.0, 1.0) : 0.0,
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
                '${(loan.amount > 0 ? (plan.totalPaid / loan.amount * 100).clamp(0, 100) : 0).toInt()}% paid',
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

  Widget _buildRepaymentProgress(RepaymentPlan plan) {
    final next = plan.next;
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Total Paid',
            value: _money.format(plan.totalPaid),
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MetricCard(
            label: 'Next Payment',
            value: next == null ? '-' : _money.format(next.remaining),
            icon: Icons.calendar_today_rounded,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MetricCard(
            label: 'Due Date',
            value: next == null ? '-' : DateFormat('d MMM').format(next.dueDate),
            icon: Icons.access_time_rounded,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdown(RepaymentPlan plan) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: AppTextStyles.labelLg.copyWith(
              color: Palette.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _breakdownRow('Amount borrowed', _money.format(plan.principal)),
          _breakdownRow('Paid so far', '-${_money.format(plan.totalPaid)}', color: AppColors.success),
          if (plan.overdueCount > 0)
            _breakdownRow('Instalments overdue', '${plan.overdueCount}', color: AppColors.error),
          const Divider(height: AppSpacing.xxl),
          _breakdownRow('Outstanding', _money.format(plan.outstanding), isBold: true, color: AppColors.accent),
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
                    color: Palette.textPrimary,
                  )
                : AppTextStyles.bodyMd.copyWith(
                    color: Palette.textSecondary,
                  ),
          ),
          Text(
            value,
            style: isBold
                ? AppTextStyles.labelLg.copyWith(
                    color: color ?? Palette.textPrimary,
                  )
                : AppTextStyles.bodyMd.copyWith(
                    color: color ?? Palette.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(Instalment item) {
    final isPaid = item.status == InstalmentStatus.paid;
    final isLate = item.status == InstalmentStatus.overdue;
    final tint = isPaid ? AppColors.success : (isLate ? AppColors.error : Palette.textTertiary);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isPaid ? Palette.successSurface : Palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isPaid || isLate ? tint.withValues(alpha: 0.3) : Palette.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPaid
                ? Icons.check_circle_rounded
                : (isLate ? Icons.error_outline_rounded : Icons.radio_button_unchecked),
            color: tint,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '${DateFormat('MMM yyyy').format(item.dueDate)}${isLate ? '  ·  overdue' : (item.status == InstalmentStatus.partial ? '  ·  part paid' : '')}',
              style: AppTextStyles.labelMd.copyWith(
                color: Palette.textPrimary,
                decoration: isPaid ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            _money.format(item.amount),
            style: AppTextStyles.labelLg.copyWith(
              color: isPaid ? AppColors.success : Palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(List<LoanPayment> payments) {
    if (payments.isEmpty) {
      return Text(
        'No payments recorded yet. Use "Record a payment" after you pay your lender.',
        style: AppTextStyles.bodyMd.copyWith(color: Palette.textTertiary),
      );
    }
    return Column(
      children: payments.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Palette.successSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.arrow_upward_rounded, color: AppColors.success, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment recorded',
                        style: AppTextStyles.labelMd.copyWith(color: Palette.textPrimary)),
                    Text('${_day.format(p.date)} · ${p.method}',
                        style: AppTextStyles.caption.copyWith(color: Palette.textTertiary)),
                  ],
                ),
              ),
              Text(_money.format(p.amount),
                  style: AppTextStyles.labelLg.copyWith(color: AppColors.success)),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showPaymentSheet(BuildContext context, Loan loan, RepaymentPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _PaymentSheet(loan: loan, plan: plan),
    );
  }
}

class _PaymentSheet extends ConsumerStatefulWidget {
  final Loan loan;
  final RepaymentPlan plan;
  const _PaymentSheet({required this.loan, required this.plan});

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  late final TextEditingController _amount;
  String _method = 'EcoCash';
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final due = widget.plan.next?.remaining;
    _amount = TextEditingController(text: due == null ? '' : due.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter the amount you paid.');
      return;
    }
    if (amount > widget.plan.outstanding + 0.005) {
      setState(() => _error = 'That is more than the ${_money.format(widget.plan.outstanding)} still owed.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final loan = widget.loan;
    await ref.read(loanRepositoryImplProvider).recordPayment(LoanPayment(
          id: const Uuid().v4(),
          loanId: loan.id,
          farmerId: ref.read(activeFarmerIdProvider),
          amount: double.parse(amount.toStringAsFixed(2)),
          date: DateTime.now(),
          method: _method,
        ));
    ref.invalidate(loanProvider);
    ref.invalidate(loanPaymentsProvider(loan.id));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Record a payment', style: AppTextStyles.h2.copyWith(color: Palette.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Log a payment you have already made to your lender. Transfarmation does not move money for you.',
            style: AppTextStyles.bodySm.copyWith(color: Palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount paid (USD)',
              prefixIcon: const Icon(Icons.attach_money_rounded),
              errorText: _error,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _method,
            decoration: const InputDecoration(
              labelText: 'How you paid',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'EcoCash', child: Text('EcoCash')),
              DropdownMenuItem(value: 'OneMoney', child: Text('OneMoney')),
              DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
            ],
            onChanged: (v) => setState(() => _method = v ?? _method),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _saving ? null : _confirm,
              child: Text(_saving ? 'Saving...' : 'Save payment'),
            ),
          ),
        ],
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
              color: Palette.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Palette.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
