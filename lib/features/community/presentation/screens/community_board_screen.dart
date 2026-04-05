import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

import '../providers/community_providers.dart';
import '../widgets/community_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityBoardScreen extends ConsumerWidget {
  const CommunityBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(forumPostsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const CreatePostDialog(),
        ),
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Start Topic'),
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

              postsAsync.when(
                data: (posts) => Column(
                  children: posts.isEmpty
                      ? [const Center(child: Text('No topics yet. Start one!'))]
                      : posts.map((post) => _ForumPostCard(post: post)).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error loading posts: $e')),
              ),
              
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
  final ForumPost post;

  const _ForumPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final isAlert = post.isAlert;
    final tags = post.tags;

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
                    post.author[0],
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(post.author, style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary)),
                const Spacer(),
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(post.region, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(post.title, style: AppTextStyles.h3.copyWith(color: isAlert ? AppColors.error : AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text(post.content, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
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
                Text(DateFormat.jm().format(post.time), style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.forum_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${post.replies} Replies', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
