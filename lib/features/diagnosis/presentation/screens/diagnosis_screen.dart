import '../../../../core/utils/picked_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/diagnosis.dart';
import '../../domain/services/symptom_matcher.dart';
import '../providers/diagnosis_providers.dart';

class DiagnosisScreen extends ConsumerWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(diagnosisHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Crop & Animal Check',
                      style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 2),
              Text('Describe what you see and get likely causes, with an agronomist on call',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: _CaptureCard(
                      title: 'Crop',
                      subtitle: 'Leaves, stems, fruit or grain',
                      icon: Icons.grass_rounded,
                      color: AppColors.primary,
                      onTap: () => context.push('/diagnosis/check?type=crop'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _CaptureCard(
                      title: 'Livestock',
                      subtitle: 'Cattle, goats, pigs, poultry',
                      icon: Icons.pets_rounded,
                      color: AppColors.secondary,
                      onTap: () => context.push('/diagnosis/check?type=livestock'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _HowItWorks(),
              const SizedBox(height: AppSpacing.xxl),
              Text('History', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              history.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Could not load history: $err')),
                data: (data) {
                  if (data.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          children: [
                            const Icon(Icons.history_rounded, size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: AppSpacing.md),
                            Text('No checks yet',
                                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [for (final d in data) _HistoryCard(diagnosis: d)],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CaptureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works', style: AppTextStyles.labelLg.copyWith(color: AppColors.info)),
          const SizedBox(height: AppSpacing.md),
          _step('1', 'Tick the signs you can see on the crop or animal'),
          _step('2', 'We compare them with our guide to pests and diseases'),
          _step('3', 'You get likely causes with an honest confidence level'),
          _step('4', 'If we are unsure, one tap sends it to an agronomist'),
        ],
      ),
    );
  }

  Widget _step(String num, String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(num,
                style: AppTextStyles.caption.copyWith(color: AppColors.info, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary))),
      ],
    ),
  );
}

class _HistoryCard extends ConsumerWidget {
  final DiagnosisResult diagnosis;
  const _HistoryCard({required this.diagnosis});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = diagnosis.matches.isEmpty ? null : diagnosis.matches.first;
    final tier = top == null ? ConfidenceTier.unsure : ConfidenceTier.fromConfidence(top.confidence);
    final color = switch (tier) {
      ConfidenceTier.likely => AppColors.success,
      ConfidenceTier.possible => AppColors.warning,
      ConfidenceTier.unsure => AppColors.error,
    };

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
                Icon(
                  diagnosis.type == 'crop' ? Icons.grass_rounded : Icons.pets_rounded,
                  size: 20,
                  color: diagnosis.type == 'crop' ? AppColors.primary : AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    top == null ? diagnosis.subjectName : '${diagnosis.subjectName}: ${top.name}',
                    style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                if (top != null)
                  Text('${(top.confidence * 100).round()}%',
                      style: AppTextStyles.h4.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(tier.label, style: AppTextStyles.labelSm.copyWith(color: color)),
            if (diagnosis.symptoms.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(diagnosis.symptoms.join(', '),
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            if (pickedImageExists(diagnosis.imagePath)) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: PickedImage(diagnosis.imagePath,
                    height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            if (diagnosis.hasReply) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Agronomist reply', style: AppTextStyles.labelMd.copyWith(color: AppColors.success)),
                    ]),
                    const SizedBox(height: AppSpacing.xs),
                    Text(diagnosis.expertReply!, style: AppTextStyles.bodySm),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (diagnosis.hasReply)
                  const SizedBox.shrink()
                else if (diagnosis.isEscalated)
                  const Chip(
                    avatar: Icon(Icons.support_agent_rounded, size: 16),
                    label: Text('Waiting for an agronomist'),
                    visualDensity: VisualDensity.compact,
                  )
                else
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(diagnosisHistoryProvider.notifier).escalate(diagnosis),
                    icon: const Icon(Icons.support_agent_rounded, size: 18),
                    label: const Text('Ask an agronomist'),
                  ),
                const Spacer(),
                Text(DateFormat.yMMMd().format(diagnosis.timestamp),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
