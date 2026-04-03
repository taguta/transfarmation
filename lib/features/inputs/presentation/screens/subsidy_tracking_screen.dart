import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/farm_input.dart';
import '../providers/input_providers.dart';

class SubsidyTrackingScreen extends ConsumerWidget {
  const SubsidyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = ref.watch(subsidyProgramsProvider);
    final applications = ref.watch(subsidyApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subsidies & Programs')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My applications
            if (applications.isNotEmpty) ...[
              Text(
                'My Applications',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              ...applications.map((app) => _ApplicationCard(application: app)),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Available programs
            Text(
              'Available Programs',
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            ...programs.map((p) => _ProgramCard(program: p)),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final SubsidyApplication application;
  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _statusColor(application.status).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_rounded,
                  color: _statusColor(application.status),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    application.programName,
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _StatusBadge(status: application.status),
              ],
            ),
            if (application.amountApproved != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Approved: \$${application.amountApproved!.toStringAsFixed(2)}',
                style: AppTextStyles.h4.copyWith(color: AppColors.success),
              ),
            ],
            if (application.notes != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                application.notes!,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Applied: ${DateFormat.yMMMd().format(application.appliedDate)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
    'approved' || 'disbursed' => AppColors.success,
    'under_review' || 'applied' => AppColors.warning,
    'rejected' => AppColors.error,
    _ => AppColors.info,
  };
}

class _ProgramCard extends StatelessWidget {
  final SubsidyProgram program;
  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    final isOpen = program.status == 'open';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
                Expanded(
                  child: Text(
                    program.name,
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isOpen
                            ? AppColors.successSurface
                            : AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    isOpen ? 'OPEN' : 'CLOSED',
                    style: AppTextStyles.caption.copyWith(
                      color: isOpen ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              program.provider,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              program.description,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Eligibility', program.eligibility),
                  const SizedBox(height: AppSpacing.xs),
                  _detailRow('Deadline', program.applicationDeadline),
                  if (program.maxAmount != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _detailRow(
                      'Max Value',
                      '\$${program.maxAmount!.toStringAsFixed(2)}',
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  _detailRow('Covers', program.coveredInputs.join(', ')),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isOpen ? () {} : null,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 80,
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
        ),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'approved' || 'disbursed' => AppColors.success,
      'under_review' || 'applied' => AppColors.warning,
      'rejected' => AppColors.error,
      _ => AppColors.info,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
