import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class ExpertListScreen extends StatelessWidget {
  const ExpertListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask an Expert'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search experts...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Specialists',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                _ExpertCard(
                  name: 'Dr. Chipo Nyathi',
                  specialty: 'Agronomist · Crop Science',
                  rating: 4.8,
                  isOnline: true,
                  onTap: () => context.go('/expert/chat'),
                ),
                const SizedBox(height: AppSpacing.md),
                _ExpertCard(
                  name: 'Eng. Tapiwa Moyo',
                  specialty: 'Irrigation & Water Management',
                  rating: 4.6,
                  isOnline: true,
                  onTap: () => context.go('/expert/chat'),
                ),
                const SizedBox(height: AppSpacing.md),
                _ExpertCard(
                  name: 'Dr. Rumbidzai Mhandu',
                  specialty: 'Veterinary · Livestock Health',
                  rating: 4.9,
                  isOnline: false,
                  onTap: () => context.go('/expert/chat'),
                ),
                const SizedBox(height: AppSpacing.md),
                _ExpertCard(
                  name: 'Mr. Blessing Chirwa',
                  specialty: 'Soil Science & Fertilizers',
                  rating: 4.5,
                  isOnline: false,
                  onTap: () => context.go('/expert/chat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final bool isOnline;
  final VoidCallback onTap;

  const _ExpertCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.advisory.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.split(' ').map((w) => w[0]).take(2).join(),
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.advisory,
                  ),
                ),
              ),
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
                          name,
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.success : AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    specialty,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.accent, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        isOnline ? 'Available' : 'Offline',
                        style: AppTextStyles.caption.copyWith(
                          color: isOnline ? AppColors.success : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
