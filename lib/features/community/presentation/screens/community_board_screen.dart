import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

// Dummy Forum Posts
final _dummyPosts = [
  {
    'author': 'Tendai M.',
    'region': 'Mashonaland West',
    'time': DateTime.now().subtract(const Duration(minutes: 45)),
    'title': 'Armyworm Outbreak near Banket',
    'content': 'Has anyone successfully used Coragen on their late maize crop? Seeing early signs of fall armyworm and want to know if it is worth the cost.',
    'replies': 12,
    'tags': ['Pests', 'Maize'],
    'isAlert': true,
  },
  {
    'author': 'Sarah B.',
    'region': 'Manicaland',
    'time': DateTime.now().subtract(const Duration(hours: 3)),
    'title': 'Best Macadamia Nurseries?',
    'content': 'Looking to expand my orchard next season. Anyone got reliable contacts for grafted Beaumont seedlings in the Vumba area?',
    'replies': 4,
    'tags': ['Macadamia', 'Sourcing'],
    'isAlert': false,
  },
];

class CommunityBoardScreen extends StatelessWidget {
  const CommunityBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create Post dialog coming soon')),
        ),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('New Topic'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
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
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Farmer Community', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 2),
              Text('Discuss tips, alerts, and market news with locals',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
                  
              const SizedBox(height: AppSpacing.xxl),

              // Region Selector / Filter Strip
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(label: 'All Regions', isActive: true),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(label: 'My District', isActive: false),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(label: 'Alerts', isActive: false, isAlert: true),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(label: 'Market Prices', isActive: false),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              ..._dummyPosts.map((post) => _ForumPostCard(post: post)),
              
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isAlert;

  const _FilterChip({required this.label, required this.isActive, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    final color = isAlert ? AppColors.error : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: isActive ? color : AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ForumPostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const _ForumPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final isAlert = post['isAlert'] as bool;
    final List<String> tags = (post['tags'] as List).cast<String>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isAlert ? AppColors.error.withValues(alpha: 0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: isAlert ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    (post['author'] as String)[0],
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(post['author'] as String, style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary)),
                const Spacer(),
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(post['region'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(post['title'] as String, style: AppTextStyles.h3.copyWith(color: isAlert ? AppColors.error : AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text(post['content'] as String, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text('#$tag', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(DateFormat.jm().format(post['time'] as DateTime), style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.forum_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${post['replies']} Replies', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
