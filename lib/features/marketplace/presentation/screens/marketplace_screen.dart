import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../providers/marketplace_providers.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final padding = context.pagePadding;
    final gridColumns = context.gridColumns(mobile: 2, tablet: 3, desktop: 4);
    final productsAsync = ref.watch(marketplaceProductsProvider(_selectedCategory));

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marketplace',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Buy and sell farm produce',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search produce, seeds, equipment...',
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
              const SizedBox(height: AppSpacing.lg),

              // Aggregation & Transport (Uber for Tractors)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        title: 'Group Sell',
                        subtitle: 'Pool harvests',
                        icon: Icons.groups_rounded,
                        color: AppColors.harvestGold,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Produce Aggregation: Pool harvests to meet commercial buyer limits.')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _FeatureCard(
                        title: 'Hire Transport',
                        subtitle: 'Uber for Tractors',
                        icon: Icons.local_shipping_rounded,
                        color: AppColors.secondary,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logistics Matching: Found 3 trucks within 10km.')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  children: [
                    _CategoryChip(
                      label: 'All',
                      icon: Icons.grid_view_rounded,
                      selected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _CategoryChip(
                      label: 'Vegetables',
                      icon: Icons.eco_rounded,
                      selected: _selectedCategory == 'Vegetables',
                      onTap: () => setState(() => _selectedCategory = 'Vegetables'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _CategoryChip(
                      label: 'Seeds',
                      icon: Icons.grain_rounded,
                      selected: _selectedCategory == 'Seeds',
                      onTap: () => setState(() => _selectedCategory = 'Seeds'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _CategoryChip(
                      label: 'Agro-Chemicals',
                      icon: Icons.science_rounded,
                      selected: _selectedCategory == 'Agro-Chemicals',
                      onTap: () => setState(() => _selectedCategory = 'Agro-Chemicals'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Listings grid — columns adapt per screen size
              Expanded(
                child: productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(child: Text("No products found in this category."));
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridColumns,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.72,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProduceCard(
                          name: product.title,
                          seller: 'Unknown Sender',
                          price: '\$${product.price.toStringAsFixed(2)}',
                          location: 'Harare',
                          icon: Icons.grass_rounded,
                          color: AppColors.primary,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/marketplace/sell'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Sell'),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
      label: Text(label),
      selected: selected,
      onSelected: (_) { if (onTap != null) onTap!(); },
      selectedColor: AppColors.primarySurface,
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMd.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
      showCheckmark: false,
    );
  }
}

class _ProduceCard extends StatelessWidget {
  final String name;
  final String seller;
  final String price;
  final String location;
  final IconData icon;
  final Color color;

  const _ProduceCard({
    required this.name,
    required this.seller,
    required this.price,
    required this.location,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Center(
                child: Icon(icon, size: 40, color: color.withValues(alpha: 0.6)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  seller,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        price,
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
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
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary)),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
