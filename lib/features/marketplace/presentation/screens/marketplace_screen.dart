import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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

            // Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: const [
                  _CategoryChip(
                    label: 'All',
                    icon: Icons.grid_view_rounded,
                    selected: true,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _CategoryChip(
                    label: 'Grains',
                    icon: Icons.grain_rounded,
                    selected: false,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _CategoryChip(
                    label: 'Vegetables',
                    icon: Icons.eco_rounded,
                    selected: false,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _CategoryChip(
                    label: 'Livestock',
                    icon: Icons.pets_rounded,
                    selected: false,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _CategoryChip(
                    label: 'Equipment',
                    icon: Icons.handyman_rounded,
                    selected: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Listings
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.72,
                children: const [
                  _ProduceCard(
                    name: 'Maize (Grade A)',
                    seller: 'Moyo Farm',
                    price: '\$280/ton',
                    location: 'Marondera',
                    icon: Icons.grass_rounded,
                    color: AppColors.primary,
                  ),
                  _ProduceCard(
                    name: 'Soya Beans',
                    seller: 'Chirinda Agri',
                    price: '\$520/ton',
                    location: 'Rusape',
                    icon: Icons.grain_rounded,
                    color: AppColors.marketplace,
                  ),
                  _ProduceCard(
                    name: 'Tobacco (Flue)',
                    seller: 'Nyanga Estates',
                    price: '\$3.20/kg',
                    location: 'Nyanga',
                    icon: Icons.eco_rounded,
                    color: AppColors.secondary,
                  ),
                  _ProduceCard(
                    name: 'Groundnuts',
                    seller: 'Mutare Farms',
                    price: '\$1,100/ton',
                    location: 'Mutare',
                    icon: Icons.spa_rounded,
                    color: AppColors.veterinary,
                  ),
                  _ProduceCard(
                    name: 'Tomatoes (Fresh)',
                    seller: 'Green Valley',
                    price: '\$0.80/kg',
                    location: 'Harare',
                    icon: Icons.local_florist_rounded,
                    color: AppColors.error,
                  ),
                  _ProduceCard(
                    name: 'Cotton Lint',
                    seller: 'Lowveld Co-op',
                    price: '\$1.50/kg',
                    location: 'Chiredzi',
                    icon: Icons.cloud_rounded,
                    color: AppColors.info,
                  ),
                ],
              ),
            ),
          ],
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

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
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
      onSelected: (_) {},
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
          Container(
            height: 100,
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

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
