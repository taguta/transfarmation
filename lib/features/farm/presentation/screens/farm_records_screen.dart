import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/farm.dart';
import '../providers/farm_providers.dart';

class FarmRecordsScreen extends ConsumerWidget {
  const FarmRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmAsync = ref.watch(farmProvider);

    return Scaffold(
      body: farmAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (farm) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Farm',
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            farm.name,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.go('/farm/add-crop'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Crop'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Farm overview card
                _buildFarmOverview(farm),
                const SizedBox(height: AppSpacing.xxl),

                // Active crops
                Text(
                  'Crops',
                  style:
                      AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                ...farm.crops.map((crop) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _CropCard(crop: crop),
                    )),

                const SizedBox(height: AppSpacing.xl),

                // Livestock
                Text(
                  'Livestock',
                  style:
                      AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildLivestockGrid(farm.livestock),

                const SizedBox(height: AppSpacing.xxl),

                // Yield summary
                Text(
                  'Yield Summary',
                  style:
                      AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildYieldSummary(farm),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFarmOverview(Farm farm) {
    final methodLabel = switch (farm.farmingMethod) {
      FarmingMethod.rainfed => 'Rainfed',
      FarmingMethod.irrigated => 'Irrigated',
      FarmingMethod.mixed => 'Mixed',
    };

    return Container(
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
              _OverviewStat(
                icon: Icons.landscape_rounded,
                label: 'Total Area',
                value: '${farm.sizeHectares.toStringAsFixed(0)} ha',
              ),
              _OverviewStat(
                icon: Icons.grass_rounded,
                label: 'Active Crops',
                value: '${farm.activeCrops}',
              ),
              _OverviewStat(
                icon: Icons.water_drop_rounded,
                label: 'Method',
                value: methodLabel,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OverviewStat(
                icon: Icons.location_on_rounded,
                label: 'Province',
                value: farm.province.split(' ').first,
              ),
              _OverviewStat(
                icon: Icons.pets_rounded,
                label: 'Livestock',
                value: '${farm.livestock.fold(0, (sum, l) => sum + l.count)}',
              ),
              _OverviewStat(
                icon: Icons.inventory_2_rounded,
                label: 'Total Yield',
                value: '${farm.totalYield.toStringAsFixed(1)}t',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLivestockGrid(List<LivestockRecord> livestock) {
    return Row(
      children: livestock.map((lv) {
        final icon = switch (lv.type.toLowerCase()) {
          'cattle' => Icons.pets_rounded,
          'goats' => Icons.cruelty_free_rounded,
          'poultry' => Icons.egg_rounded,
          _ => Icons.pets_rounded,
        };
        final color = switch (lv.type.toLowerCase()) {
          'cattle' => AppColors.secondary,
          'goats' => AppColors.veterinary,
          'poultry' => AppColors.accent,
          _ => AppColors.primary,
        };
        final isHealthy = lv.healthStatus?.toLowerCase().contains('healthy') ?? true;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: lv != livestock.last ? AppSpacing.md : 0,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  lv.type,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${lv.count}',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle : Icons.warning_rounded,
                      size: 12,
                      color: isHealthy ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        lv.healthStatus ?? 'Unknown',
                        style: AppTextStyles.caption.copyWith(
                          color: isHealthy
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYieldSummary(Farm farm) {
    final harvested =
        farm.crops.where((c) => c.status == CropStatus.harvested).toList();
    if (harvested.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Center(
          child: Text(
            'No harvested crops yet this season',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: harvested.map((crop) {
        final efficiency = crop.expectedYield != null && crop.expectedYield! > 0
            ? (crop.actualYield ?? 0) / crop.expectedYield!
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.cropName,
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${crop.areHectares.toStringAsFixed(1)} ha · ${crop.yieldPerHectare.toStringAsFixed(1)} t/ha',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${crop.actualYield?.toStringAsFixed(1) ?? '0'} tons',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${(efficiency * 100).toInt()}% of target',
                    style: AppTextStyles.caption.copyWith(
                      color: efficiency >= 0.9
                          ? AppColors.success
                          : efficiency >= 0.7
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLg.copyWith(color: Colors.white),
        ),
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

class _CropCard extends StatelessWidget {
  final CropRecord crop;

  const _CropCard({required this.crop});

  Color get _statusColor => switch (crop.status) {
        CropStatus.planted => AppColors.info,
        CropStatus.growing => AppColors.primary,
        CropStatus.harvesting => AppColors.accent,
        CropStatus.harvested => AppColors.success,
        CropStatus.fallow => AppColors.textTertiary,
      };

  String get _statusLabel => switch (crop.status) {
        CropStatus.planted => 'Planted',
        CropStatus.growing => 'Growing',
        CropStatus.harvesting => 'Harvesting',
        CropStatus.harvested => 'Harvested',
        CropStatus.fallow => 'Fallow',
      };

  IconData get _cropIcon => switch (crop.cropName.toLowerCase()) {
        'maize' => Icons.grass_rounded,
        'soya beans' || 'soya' => Icons.grain_rounded,
        'tobacco' => Icons.eco_rounded,
        'groundnuts' => Icons.spa_rounded,
        'cotton' => Icons.cloud_rounded,
        _ => Icons.grass_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final daysToHarvest = crop.expectedHarvest
        ?.difference(DateTime.now()).inDays;
    final growthProgress = crop.expectedHarvest != null
        ? 1 -
            (crop.expectedHarvest!.difference(DateTime.now()).inDays /
                crop.expectedHarvest!
                    .difference(crop.plantedDate)
                    .inDays)
                .clamp(0, 1)
        : 0.0;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(_cropIcon, color: _statusColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.cropName,
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${crop.areHectares.toStringAsFixed(1)} hectares',
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
          if (crop.status == CropStatus.growing ||
              crop.status == CropStatus.planted) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expected: ${crop.expectedYield?.toStringAsFixed(1) ?? '–'} tons',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (daysToHarvest != null && daysToHarvest > 0)
                  Text(
                    '$daysToHarvest days to harvest',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: growthProgress.toDouble(),
                backgroundColor: AppColors.border,
                color: _statusColor,
                minHeight: 4,
              ),
            ),
          ],
          if (crop.status == CropStatus.harvested) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yield: ${crop.actualYield?.toStringAsFixed(1) ?? '–'} tons',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${crop.yieldPerHectare.toStringAsFixed(1)} t/ha',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (crop.notes != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.sticky_note_2_outlined,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    crop.notes!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
