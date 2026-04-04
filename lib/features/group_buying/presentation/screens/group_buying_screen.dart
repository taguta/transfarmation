import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/cooperative.dart';
import '../providers/group_buying_providers.dart';

class GroupBuyingScreen extends ConsumerWidget {
  const GroupBuyingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coopsAsync = ref.watch(cooperativesProvider);
    final coops = coopsAsync.value ?? [];
    final allOrders = ref.watch(allGroupOrdersProvider);
    final openOrders = allOrders.where((e) => e.value.status == 'open').toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Group Buying', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('Buy together, save together',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),

              const SizedBox(height: AppSpacing.xxl),

              // Open orders header
              Row(
                children: [
                  Text('Open Group Orders', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.harvestGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${openOrders.length} active',
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.harvestGold, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...openOrders.map((entry) => _GroupOrderCard(coop: entry.key, order: entry.value)),

              const SizedBox(height: AppSpacing.xxl),

              // Cooperatives
              Text('Cooperatives', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              ...coops.map((c) => _CoopCard(coop: c)),

              const SizedBox(height: AppSpacing.xxl),

              // How it works
              _HowItWorksCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Group order card ---
class _GroupOrderCard extends StatelessWidget {
  final Cooperative coop;
  final GroupOrder order;
  const _GroupOrderCard({required this.coop, required this.order});

  @override
  Widget build(BuildContext context) {
    final daysLeft = order.deadline.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.productName, style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '-${order.discountPercent.toStringAsFixed(0)}%',
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.forestGreen, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${coop.name} • ${order.supplier}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),

          const SizedBox(height: AppSpacing.md),

          // Price comparison
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Retail', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                  Text(
                    '\$${order.unitPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xl),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Group Price', style: AppTextStyles.labelSm.copyWith(color: AppColors.forestGreen)),
                  Text(
                    '\$${order.bulkPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.h3.copyWith(color: AppColors.forestGreen),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('per ${order.unit.split(' ').last.replaceAll('(', '').replaceAll(')', '')}',
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                  Text(
                    '${daysLeft}d left',
                    style: AppTextStyles.labelSm.copyWith(
                      color: daysLeft < 7 ? Colors.redAccent : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: order.progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.borderLight,
                        color: order.progress >= 1.0 ? AppColors.forestGreen : AppColors.harvestGold,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.currentQuantity}/${order.minimumQuantity} ${order.unit}',
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Joined \${order.productName} order. Saved locally and synced.')),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Cooperative card ---
class _CoopCard extends StatelessWidget {
  final Cooperative coop;
  const _CoopCard({required this.coop});

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'crop': return Icons.grass_rounded;
      case 'livestock': return Icons.pets_rounded;
      default: return Icons.groups_rounded;
    }
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'crop': return AppColors.forestGreen;
      case 'livestock': return AppColors.earthBrown;
      default: return AppColors.harvestGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _catColor(coop.category);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(_catIcon(coop.category), size: 24, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coop.name, style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary)),
                Text('${coop.region} • ${coop.memberCount} members',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '${coop.activeOrders.length} active order${coop.activeOrders.length == 1 ? '' : 's'}',
                  style: AppTextStyles.labelSm.copyWith(color: color),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// --- How it works ---
class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.forestGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How Group Buying Works', style: AppTextStyles.h4.copyWith(color: AppColors.forestGreen)),
          const SizedBox(height: AppSpacing.md),
          _Step(num: '1', text: 'Join or create a cooperative in your area'),
          _Step(num: '2', text: 'Browse group orders or start a new bulk purchase'),
          _Step(num: '3', text: 'Commit your quantity — once minimum is met, order is confirmed'),
          _Step(num: '4', text: 'Pay at group price — save 15-30% vs retail'),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String num;
  final String text;
  const _Step({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.forestGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(num, style: AppTextStyles.labelSm.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
