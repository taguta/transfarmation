import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/pest_disease.dart';
import '../providers/knowledge_providers.dart';

class PestDiseaseDetailScreen extends ConsumerWidget {
  final String pestId;
  const PestDiseaseDetailScreen({super.key, required this.pestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pestsAsync = ref.watch(pestsDiseasesProvider);
    return pestsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (items) {
        final item = items.where((p) => p.id == pestId).firstOrNull;
        if (item == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Not found')));
        }
        return _PestDetailBody(item: item);
      },
    );
  }
}

class _PestDetailBody extends StatelessWidget {
  final PestDisease item;
  const _PestDetailBody({required this.item});

  Color get _severityColor => switch (item.severity) {
        'critical' => AppColors.error,
        'high' => AppColors.warning,
        'medium' => AppColors.accent,
        _ => AppColors.info,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_severityColor, _severityColor.withValues(alpha: 0.7)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.type == 'pest' ? Icons.bug_report_rounded : Icons.coronavirus_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type + severity + affects
                  Row(
                    children: [
                      _badge(item.type.toUpperCase(), AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      _badge(item.severity.toUpperCase(), _severityColor),
                      const SizedBox(width: AppSpacing.sm),
                      _badge('Affects ${item.affects}', AppColors.secondary),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(item.description, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary)),

                  const SizedBox(height: AppSpacing.xxl),
                  _alertCard('Symptoms', item.symptoms, Icons.visibility_rounded, AppColors.warning),
                  const SizedBox(height: AppSpacing.md),
                  _alertCard('Treatment', item.treatment, Icons.medical_services_rounded, AppColors.success),
                  const SizedBox(height: AppSpacing.md),
                  _alertCard('Prevention', item.prevention, Icons.shield_rounded, AppColors.info),

                  if (item.affectedCrops.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _section('Affected Crops'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: item.affectedCrops
                          .map((c) => Chip(
                                avatar: const Icon(Icons.grass_rounded, size: 16),
                                label: Text(c),
                                backgroundColor: AppColors.primarySurface,
                              ))
                          .toList(),
                    ),
                  ],

                  if (item.affectedLivestock.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _section('Affected Livestock'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: item.affectedLivestock
                          .map((l) => Chip(
                                avatar: const Icon(Icons.pets_rounded, size: 16),
                                label: Text(l),
                                backgroundColor: AppColors.secondarySurface,
                              ))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) =>
      Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary));

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(text, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
      );

  Widget _alertCard(String title, String content, IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTextStyles.h4.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(content, style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      );
}
