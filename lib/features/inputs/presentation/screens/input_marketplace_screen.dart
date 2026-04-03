import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/farm_input.dart';
import '../providers/input_providers.dart';

class InputMarketplaceScreen extends ConsumerStatefulWidget {
  const InputMarketplaceScreen({super.key});

  @override
  ConsumerState<InputMarketplaceScreen> createState() =>
      _InputMarketplaceScreenState();
}

class _InputMarketplaceScreenState
    extends ConsumerState<InputMarketplaceScreen> {
  String _selectedCategory = 'all';

  static const _categories = [
    ('all', 'All', Icons.grid_view_rounded),
    ('seeds', 'Seeds', Icons.grass_rounded),
    ('fertilizer', 'Fertilizer', Icons.science_rounded),
    ('chemicals', 'Chemicals', Icons.sanitizer_rounded),
    ('equipment', 'Equipment', Icons.construction_rounded),
    ('feed', 'Feed', Icons.restaurant_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final inputs = ref.watch(inputCategoryProvider(_selectedCategory));
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Farm Inputs',
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Seeds, fertilizer, chemicals & equipment',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.receipt_long_rounded),
                        tooltip: 'Subsidies',
                        onPressed: () => context.push('/inputs/subsidies'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children:
                    _categories.map((c) {
                      final isSelected = _selectedCategory == c.$1;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(c.$2),
                          avatar: Icon(c.$3, size: 16),
                          onSelected:
                              (_) => setState(() => _selectedCategory = c.$1),
                          selectedColor: AppColors.primarySurface,
                          checkmarkColor: AppColors.primary,
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Product list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: inputs.length,
                itemBuilder: (context, i) => _InputCard(input: inputs[i]),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final FarmInput input;
  const _InputCard({required this.input});

  @override
  Widget build(BuildContext context) {
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _categoryColor(
                      input.category,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _categoryIcon(input.category),
                    color: _categoryColor(input.category),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        input.name,
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        input.supplier,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (input.isVerified)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              input.description,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  '\$${input.price.toStringAsFixed(2)}',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
                Text(
                  ' / ${input.unit}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                if (input.bulkPrice != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSurface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'Bulk: \$${input.bulkPrice!.toStringAsFixed(2)} (${input.bulkMinQuantity}+)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (!input.inStock)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'Out of Stock',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: input.inStock ? () {} : null,
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: const Text('Add to Cart'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (input.bulkPrice != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: input.inStock ? () {} : null,
                      icon: const Icon(Icons.group_rounded, size: 18),
                      label: const Text('Group Buy'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String cat) => switch (cat) {
    'seeds' => AppColors.primary,
    'fertilizer' => AppColors.accent,
    'chemicals' => AppColors.warning,
    'equipment' => AppColors.secondary,
    'feed' => AppColors.marketplace,
    _ => AppColors.info,
  };

  IconData _categoryIcon(String cat) => switch (cat) {
    'seeds' => Icons.grass_rounded,
    'fertilizer' => Icons.science_rounded,
    'chemicals' => Icons.sanitizer_rounded,
    'equipment' => Icons.construction_rounded,
    'feed' => Icons.restaurant_rounded,
    _ => Icons.inventory_2_rounded,
  };
}
