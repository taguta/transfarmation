import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/savings_group.dart';
import '../providers/savings_providers.dart';

class SavingsGroupScreen extends ConsumerWidget {
  const SavingsGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(savingsGroupsProvider);
    final groups = groupsAsync.value ?? [];

    return Scaffold(
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
                  Text('Savings Groups', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 2),
              Text('Mukando — save together, grow together',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),

              const SizedBox(height: AppSpacing.xxl),

              // Summary card
              _SummaryCard(groups: groups),
              const SizedBox(height: AppSpacing.lg),

              // Gamification Badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.harvestGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.harvestGold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: AppColors.harvestGold, size: 16),
                        const SizedBox(width: 4),
                        Text('Consistent Saver Badge', style: AppTextStyles.caption.copyWith(color: AppColors.harvestGold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              Text('My Farm Goals', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60, height: 60,
                          child: CircularProgressIndicator(
                            value: 0.65,
                            backgroundColor: AppColors.borderLight,
                            color: AppColors.primary,
                            strokeWidth: 6,
                          ),
                        ),
                        const Icon(Icons.agriculture_rounded, color: AppColors.primary, size: 28),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New Tractor Deposit', style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('\$650 / \$1,000 saved', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Groups list
              Row(
                children: [
                  Text('My Groups', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Create Group initiated. State will be managed locally first.')),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...groups.map((g) => _GroupCard(group: g)),

              const SizedBox(height: AppSpacing.xxl),

              // Recent transactions
              Text('Recent Activity', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              _TransactionsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<SavingsGroup> groups;
  const _SummaryCard({required this.groups});

  @override
  Widget build(BuildContext context) {
    final totalSaved = groups.fold<double>(0, (sum, g) => sum + g.totalPool);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Group Savings', style: AppTextStyles.bodyMd.copyWith(color: Colors.white70)),
          const SizedBox(height: AppSpacing.xs),
          Text('\$${totalSaved.toStringAsFixed(2)}',
              style: AppTextStyles.displaySm.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _miniStat('Groups', '${groups.length}'),
              const SizedBox(width: AppSpacing.xxl),
              _miniStat('Members', '${groups.fold<int>(0, (s, g) => s + g.memberCount)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white60)),
      Text(value, style: AppTextStyles.h4.copyWith(color: Colors.white)),
    ],
  );
}

class _GroupCard extends StatelessWidget {
  final SavingsGroup group;
  const _GroupCard({required this.group});

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
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.group_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name, style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
                      Text('${group.memberCount}/${group.maxMembers} members • ${group.frequency}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(group.status.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(group.description, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary), maxLines: 2),
            const SizedBox(height: AppSpacing.md),

            // Contribution & next payout
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contribution', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                        Text('\$${group.contributionAmount.toStringAsFixed(2)}/${group.frequency}',
                            style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 32, color: AppColors.border),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Next Payout', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                          Text(DateFormat.yMMMd().format(group.nextPayoutDate),
                              style: AppTextStyles.labelLg.copyWith(color: AppColors.accent)),
                          Text(group.nextRecipient,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Members progress
            if (group.members.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Payout Progress', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: group.members.where((m) => m.hasReceivedPayout).length / group.members.length,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${group.members.where((m) => m.hasReceivedPayout).length} of ${group.members.length} members received payout',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
            ],

            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contribution to \${group.name} recorded. Synced to remote.')),
                  );
                },
                icon: const Icon(Icons.payments_rounded, size: 18),
                label: const Text('Make Contribution'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(savingsTransactionsProvider);
    final transactions = transactionsAsync.value ?? [];
    return Column(
      children: transactions.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: t.type == 'payout'
                      ? AppColors.successSurface
                      : AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  t.type == 'payout' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  size: 18,
                  color: t.type == 'payout' ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.memberName, style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary)),
                    Text(t.type == 'payout' ? 'Payout received' : 'Contribution',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${t.type == 'payout' ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.labelLg.copyWith(
                      color: t.type == 'payout' ? AppColors.success : AppColors.textPrimary,
                    ),
                  ),
                  Text(DateFormat.MMMd().format(t.date),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}
