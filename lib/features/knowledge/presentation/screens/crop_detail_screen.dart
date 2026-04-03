import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/crop.dart';
import '../providers/knowledge_providers.dart';

class CropDetailScreen extends ConsumerWidget {
  final String cropId;
  const CropDetailScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync = ref.watch(cropsProvider);
    return cropsAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (crops) {
        final crop = crops.where((c) => c.id == cropId).firstOrNull;
        if (crop == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Crop not found')),
          );
        }
        return _CropDetailBody(crop: crop);
      },
    );
  }
}

class _CropDetailBody extends StatelessWidget {
  final Crop crop;
  const _CropDetailBody({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                crop.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: Center(
                  child: Icon(
                    Icons.grass_rounded,
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
                  // Scientific name + category
                  Row(
                    children: [
                      Text(
                        crop.scientificName,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          crop.category.replaceAll('_', ' ').toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    crop.description,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  _sectionTitle('Growing Information'),
                  const SizedBox(height: AppSpacing.md),
                  _infoRow(
                    Icons.calendar_today_rounded,
                    'Planting',
                    crop.plantingSeason,
                  ),
                  _infoRow(
                    Icons.agriculture_rounded,
                    'Harvest',
                    crop.harvestSeason,
                  ),
                  _infoRow(
                    Icons.timer_rounded,
                    'Duration',
                    crop.growthDuration,
                  ),
                  _infoRow(
                    Icons.water_drop_rounded,
                    'Water',
                    crop.waterRequirements,
                  ),
                  _infoRow(Icons.landscape_rounded, 'Soil', crop.soilType),
                  _infoRow(Icons.straighten_rounded, 'Spacing', crop.spacing),
                  _infoRow(
                    Icons.inventory_2_rounded,
                    'Yield/ha',
                    crop.yieldPerHectare,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  _sectionTitle('Agro-Ecological Regions'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children:
                        crop.regions
                            .map(
                              (r) => Chip(
                                label: Text('Region $r'),
                                backgroundColor: AppColors.primarySurface,
                                labelStyle: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  _sectionTitle('Common Pests'),
                  const SizedBox(height: AppSpacing.sm),
                  ...crop.commonPests.map(
                    (p) => _bulletItem(
                      p,
                      Icons.bug_report_rounded,
                      AppColors.warning,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  _sectionTitle('Common Diseases'),
                  const SizedBox(height: AppSpacing.sm),
                  ...crop.commonDiseases.map(
                    (d) => _bulletItem(
                      d,
                      Icons.coronavirus_rounded,
                      AppColors.error,
                    ),
                  ),

                  if (crop.tips.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _sectionTitle('Farmer Tips'),
                    const SizedBox(height: AppSpacing.md),
                    ...crop.tips.map((t) => _tipCard(t.title, t.content)),
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

  Widget _sectionTitle(String title) => Text(
    title,
    style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
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
    ),
  );

  Widget _bulletItem(String text, IconData icon, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    ),
  );

  Widget _tipCard(String title, String content) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            content,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}
