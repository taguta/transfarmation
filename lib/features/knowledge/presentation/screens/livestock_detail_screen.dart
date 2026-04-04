import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/livestock.dart';
import '../providers/knowledge_providers.dart';

class LivestockDetailScreen extends ConsumerWidget {
  final String livestockId;
  const LivestockDetailScreen({super.key, required this.livestockId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestockAsync = ref.watch(livestockProvider);
    return livestockAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (items) {
        final item = items.where((l) => l.id == livestockId).firstOrNull;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: Text('Not found')),
          );
        }
        return _LivestockDetailBody(item: item);
      },
    );
  }
}

class _LivestockDetailBody extends StatelessWidget {
  final Livestock item;
  const _LivestockDetailBody({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: Center(
                  child: Icon(Icons.pets_rounded, size: 64, color: Colors.white.withValues(alpha: 0.3)),
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
                  Row(
                    children: [
                      Text(item.breed,
                          style: AppTextStyles.bodyMd.copyWith(
                              fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(item.category.toUpperCase(),
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(item.description, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary)),

                  const SizedBox(height: AppSpacing.xxl),
                  _section('Production Details'),
                  const SizedBox(height: AppSpacing.md),
                  _infoRow(Icons.monitor_weight_rounded, 'Weight', item.averageWeight),
                  _infoRow(Icons.calendar_month_rounded, 'Maturity', item.maturityAge),
                  _infoRow(Icons.inventory_rounded, 'Output', item.productionOutput),

                  const SizedBox(height: AppSpacing.xxl),
                  _section('Management'),
                  const SizedBox(height: AppSpacing.md),
                  _infoCard(Icons.restaurant_rounded, 'Feed Requirements', item.feedRequirements),
                  const SizedBox(height: AppSpacing.sm),
                  _infoCard(Icons.house_rounded, 'Housing', item.housingRequirements),
                  const SizedBox(height: AppSpacing.sm),
                  _infoCard(Icons.favorite_rounded, 'Breeding', item.breedingCycle),

                  const SizedBox(height: AppSpacing.xxl),
                  _section('Health'),
                  const SizedBox(height: AppSpacing.md),
                  Text('Common Diseases',
                      style: AppTextStyles.labelLg.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.xs),
                  ...item.commonDiseases.map((d) => _bulletItem(d, Icons.coronavirus_rounded, AppColors.error)),

                  if (item.vaccinations.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text('Vaccination Schedule',
                        style: AppTextStyles.labelLg.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.xs),
                    ...item.vaccinations.map((v) => _bulletItem(v, Icons.vaccines_rounded, AppColors.success)),
                  ],

                  if (item.tips.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _section('Farmer Tips'),
                    const SizedBox(height: AppSpacing.md),
                    ...item.tips.map((t) => _tipCard(t.title, t.content)),
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

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 70,
              child: Text(label,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Text(value, style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary))),
          ],
        ),
      );

  Widget _infoCard(IconData icon, String title, String content) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(title, style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(content, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _bulletItem(String text, IconData icon, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(text, style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary))),
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
              Row(children: [
                const Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.accent),
                const SizedBox(width: AppSpacing.xs),
                Text(title, style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: AppSpacing.xs),
              Text(content, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}
