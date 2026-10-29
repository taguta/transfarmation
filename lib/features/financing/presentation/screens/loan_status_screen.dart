import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../ledger/domain/farmer_statement.dart';
import '../../../ledger/presentation/providers/ledger_providers.dart';
import '../../domain/entities/loan.dart';
import '../../domain/services/loan_file_pdf.dart';
import '../providers/loan_providers.dart';

enum _LoanFilter { all, active, pending, completed }

bool _isLive(Loan l) =>
    l.status == LoanStatus.approved || l.status == LoanStatus.disbursed;

bool _matches(_LoanFilter f, Loan l) => switch (f) {
  _LoanFilter.all => true,
  _LoanFilter.active => _isLive(l) && l.repaidPercent < 1.0,
  _LoanFilter.pending =>
    l.status == LoanStatus.pending || l.status == LoanStatus.draft,
  _LoanFilter.completed =>
    l.status == LoanStatus.completed || (_isLive(l) && l.repaidPercent >= 1.0),
};

/// The farmer's own loans, read from local storage. Nothing here is sample data.
class LoanStatusScreen extends ConsumerStatefulWidget {
  const LoanStatusScreen({super.key});

  @override
  ConsumerState<LoanStatusScreen> createState() => _LoanStatusScreenState();
}

class _LoanStatusScreenState extends ConsumerState<LoanStatusScreen> {
  _LoanFilter _filter = _LoanFilter.all;

  Future<void> _shareLoanFile(Loan loan) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final loans = ref.read(loanProvider).valueOrNull ?? const <Loan>[];
      final entries = await ref.read(ledgerEntriesProvider.future);
      final name = ref.read(authStateProvider).valueOrNull?.displayName ?? '';
      final bytes = await LoanFilePdf.build(
        loan: loan,
        statement: FarmerStatement.build(entries: entries, loans: loans),
        entries: entries,
        farmerName: name,
        sharedWith: loan.lenderName,
      );
      await Printing.sharePdf(bytes: bytes, filename: 'loan-file-${loan.id}.pdf');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not create the loan file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loanProvider);
    final all = loansAsync.valueOrNull ?? const <Loan>[];
    final shown = all.where((l) => _matches(_filter, l)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          style: AppTextStyles.h1.copyWith(color: Palette.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track your loans and repayments',
                          style: AppTextStyles.bodyMd.copyWith(color: Palette.textSecondary),
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

            if (all.isNotEmpty) _PortfolioSummary(loans: all),
            const SizedBox(height: AppSpacing.md),

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

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  for (final f in _LoanFilter.values) ...[
                    FilterChip(
                      label: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: Palette.primarySurface,
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.labelMd.copyWith(
                        color: _filter == f ? AppColors.primary : Palette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Expanded(
              child: loansAsync.isLoading && all.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : shown.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Text(
                              all.isEmpty
                                  ? 'No loans yet. Build a feasibility plan, then apply.'
                                  : 'No loans in this view.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: Palette.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxxl,
                          ),
                          itemCount: shown.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, i) => _LoanListItem(
                            loan: shown[i],
                            onLoanFile: () => _shareLoanFile(shown[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  final List<Loan> loans;
  const _PortfolioSummary({required this.loans});

  @override
  Widget build(BuildContext context) {
    final live = loans.where(
      (l) => _isLive(l) || l.status == LoanStatus.completed,
    );
    final borrowed = live.fold<double>(0, (s, l) => s + l.amount);
    final repaid = live.fold<double>(0, (s, l) => s + l.amountRepaid);
    final outstanding = (borrowed - repaid).clamp(0, double.infinity).toDouble();
    final pct = borrowed > 0 ? (repaid / borrowed).clamp(0.0, 1.0) : 0.0;
    final money = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PortfolioStat(label: 'Total Borrowed', value: money.format(borrowed)),
              _PortfolioStat(label: 'Repaid', value: money.format(repaid)),
              _PortfolioStat(label: 'Outstanding', value: money.format(outstanding)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: AppColors.accentLight,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(pct * 100).round()}% of approved loans repaid',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
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

class _LoanListItem extends StatelessWidget {
  final Loan loan;
  final VoidCallback onLoanFile;

  const _LoanListItem({required this.loan, required this.onLoanFile});

  bool get _isRepaying => _isLive(loan) && loan.repaidPercent < 1.0;

  Color get _statusColor => switch (loan.status) {
    LoanStatus.approved ||
    LoanStatus.disbursed ||
    LoanStatus.completed => AppColors.loanApproved,
    LoanStatus.pending => AppColors.loanPending,
    LoanStatus.rejected => AppColors.loanRejected,
    LoanStatus.draft => AppColors.loanDraft,
  };

  String get _statusLabel => switch (loan.status) {
    LoanStatus.approved || LoanStatus.disbursed =>
      loan.repaidPercent >= 1.0 ? 'Completed' : 'Active',
    LoanStatus.completed => 'Completed',
    LoanStatus.pending => 'Pending',
    LoanStatus.rejected => 'Rejected',
    LoanStatus.draft => 'Draft',
  };

  @override
  Widget build(BuildContext context) {
    final title = loan.purpose ?? loan.cropType ?? 'Loan application';
    final lender = loan.lenderName ?? 'Waiting for a lender';
    final date = DateFormat.yMMM().format(loan.createdAt);

    return GestureDetector(
      onTap: _isRepaying ? () => context.go('/financing/repayments') : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Palette.border),
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
                  child: Icon(Icons.account_balance_rounded, color: _statusColor, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.labelLg.copyWith(color: Palette.textPrimary),
                      ),
                      Text(
                        lender,
                        style: AppTextStyles.caption.copyWith(color: Palette.textTertiary),
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
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${loan.amount.toStringAsFixed(0)}',
                  style: AppTextStyles.h3.copyWith(color: Palette.textPrimary),
                ),
                Text(
                  _isRepaying ? '${(loan.repaidPercent * 100).toInt()}% repaid' : date,
                  style: AppTextStyles.caption.copyWith(color: Palette.textTertiary),
                ),
              ],
            ),
            if (_isRepaying) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: loan.repaidPercent,
                  backgroundColor: Palette.border,
                  color: AppColors.primary,
                  minHeight: 4,
                ),
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onLoanFile,
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: const Text('Loan file (PDF)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
