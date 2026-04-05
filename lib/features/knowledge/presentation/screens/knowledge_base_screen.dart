import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../providers/knowledge_providers.dart';

class KnowledgeBaseScreen extends ConsumerStatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  ConsumerState<KnowledgeBaseScreen> createState() =>
      _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends ConsumerState<KnowledgeBaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.pagePadding;
    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/services');
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Knowledge Base',
                          style: AppTextStyles.h1
                              .copyWith(color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0),
                    child: Text(
                      'Offline farming encyclopedia',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search crops, livestock, pests...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.grass_rounded), text: 'Crops'),
                Tab(icon: Icon(Icons.pets_rounded), text: 'Livestock'),
                Tab(icon: Icon(Icons.bug_report_rounded), text: 'Pests'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CropsTab(searchQuery: _searchQuery),
                  _LivestockTab(searchQuery: _searchQuery),
                  _PestDiseaseTab(searchQuery: _searchQuery),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ─── Crops Tab ─────────────────────────────────────────
class _CropsTab extends ConsumerWidget {
  final String searchQuery;
  const _CropsTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync = ref.watch(cropSearchProvider(searchQuery));
    return cropsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (crops) => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: crops.length,
        itemBuilder: (context, i) {
          final crop = crops[i];
          return _KnowledgeCard(
            title: crop.name,
            subtitle: crop.scientificName,
            category: crop.category.replaceAll('_', ' ').toUpperCase(),
            categoryColor: _cropCategoryColor(crop.category),
            icon: Icons.grass_rounded,
            tags: crop.regions.map((r) => 'Region $r').toList(),
            onTap: () => context.push('/knowledge/crop/${crop.id}'),
          );
        },
      ),
    );
  }

  Color _cropCategoryColor(String cat) => switch (cat) {
        'grain' => AppColors.accent,
        'cash_crop' => AppColors.primary,
        'horticulture' => AppColors.marketplace,
        'indigenous' => AppColors.secondary,
        _ => AppColors.info,
      };
}

// ─── Livestock Tab ─────────────────────────────────────
class _LivestockTab extends ConsumerWidget {
  final String searchQuery;
  const _LivestockTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestockAsync = ref.watch(livestockSearchProvider(searchQuery));
    return livestockAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (items) => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return _KnowledgeCard(
            title: item.name,
            subtitle: item.breed,
            category: item.category.toUpperCase(),
            categoryColor: _livestockCategoryColor(item.category),
            icon: _livestockIcon(item.category),
            tags: [item.maturityAge, item.averageWeight],
            onTap: () => context.push('/knowledge/livestock/${item.id}'),
          );
        },
      ),
    );
  }

  Color _livestockCategoryColor(String cat) => switch (cat) {
        'cattle' => AppColors.secondary,
        'goats' => AppColors.accent,
        'poultry' => AppColors.warning,
        'pigs' => AppColors.error,
        'rabbits' => AppColors.info,
        'fish' => AppColors.marketplace,
        _ => AppColors.primary,
      };

  IconData _livestockIcon(String cat) => switch (cat) {
        'cattle' => Icons.pets_rounded,
        'goats' => Icons.pets_rounded,
        'poultry' => Icons.egg_rounded,
        'pigs' => Icons.pets_rounded,
        'rabbits' => Icons.cruelty_free_rounded,
        'fish' => Icons.water_rounded,
        _ => Icons.pets_rounded,
      };
}

// ─── Pest/Disease Tab ──────────────────────────────────
class _PestDiseaseTab extends ConsumerWidget {
  final String searchQuery;
  const _PestDiseaseTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pestsAsync = ref.watch(pestDiseaseSearchProvider(searchQuery));
    return pestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (items) => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return _KnowledgeCard(
            title: item.name,
            subtitle: '${item.type.toUpperCase()} — Affects ${item.affects}',
            category: item.severity.toUpperCase(),
            categoryColor: _severityColor(item.severity),
            icon: item.type == 'pest'
                ? Icons.bug_report_rounded
                : Icons.coronavirus_rounded,
            tags: [
              ...item.affectedCrops,
              ...item.affectedLivestock,
            ],
            onTap: () => context.push('/knowledge/pest/${item.id}'),
          );
        },
      ),
    );
  }

  Color _severityColor(String severity) => switch (severity) {
        'critical' => AppColors.error,
        'high' => AppColors.warning,
        'medium' => AppColors.accent,
        _ => AppColors.info,
      };
}

// ─── Shared knowledge card ─────────────────────────────
class _KnowledgeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;
  final Color categoryColor;
  final IconData icon;
  final List<String> tags;
  final VoidCallback onTap;

  const _KnowledgeCard({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.categoryColor,
    required this.icon,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: categoryColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              category,
                              style: AppTextStyles.caption.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: tags
                              .take(4)
                              .map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.xs),
                                  ),
                                  child: Text(
                                    t,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
