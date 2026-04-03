import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/farming_contract.dart';
import '../providers/contract_providers.dart';

class ContractFarmingScreen extends ConsumerWidget {
  const ContractFarmingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(filteredContractsProvider);
    final filter = ref.watch(contractFilterProvider);

    final filters = ['all', 'open', 'applied', 'active'];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contract Farming', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('Guaranteed markets with input support',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),

              const SizedBox(height: AppSpacing.lg),

              // Filter chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final f = filters[index];
                    final isSelected = f == filter;
                    return GestureDetector(
                      onTap: () => ref.read(contractFilterProvider.notifier).state = f,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.forestGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: isSelected ? AppColors.forestGreen : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          f[0].toUpperCase() + f.substring(1),
                          style: AppTextStyles.labelSm.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Contract cards
              ...contracts.map((c) => _ContractCard(contract: c)),

              if (contracts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(
                    child: Text('No contracts found for this filter',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),
              _BenefitsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Contract card ---
class _ContractCard extends ConsumerWidget {
  final FarmingContract contract;
  const _ContractCard({required this.contract});

  Color _statusColor(String status) {
    switch (status) {
      case 'open': return AppColors.harvestGold;
      case 'applied': return Colors.blue;
      case 'accepted': return AppColors.forestGreen;
      case 'active': return AppColors.forestGreen;
      case 'completed': return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'processor': return Icons.factory_rounded;
      case 'exporter': return Icons.flight_takeoff_rounded;
      case 'retailer': return Icons.storefront_rounded;
      case 'government': return Icons.account_balance_rounded;
      default: return Icons.business_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(contract.status);
    final daysLeft = contract.deadline.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.earthBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(_typeIcon(contract.buyerType), size: 20, color: AppColors.earthBrown),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contract.buyerName, style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary)),
                    Text(
                      contract.buyerType[0].toUpperCase() + contract.buyerType.substring(1),
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  contract.status.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Commodity & price
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commodity', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                      Text(contract.commodity, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Price', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                    Text(
                      '\$${contract.pricePerUnit.toStringAsFixed(contract.pricePerUnit < 10 ? 2 : 0)} ${contract.unit}',
                      style: AppTextStyles.h4.copyWith(color: AppColors.forestGreen),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Details
          Row(
            children: [
              _DetailChip(icon: Icons.straighten_rounded, label: 'Min: ${contract.minQuantity} ${contract.unit.split(' ').last}'),
              const SizedBox(width: AppSpacing.sm),
              _DetailChip(icon: Icons.calendar_today_rounded, label: contract.season),
              const SizedBox(width: AppSpacing.sm),
              _DetailChip(icon: Icons.location_on_rounded, label: contract.region.split(' &').first),
            ],
          ),

          // What buyer provides
          if (contract.buyerProvides.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Text('Buyer Provides', style: AppTextStyles.labelMd.copyWith(color: AppColors.forestGreen)),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: contract.buyerProvides.map((p) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(p, style: AppTextStyles.labelSm.copyWith(color: AppColors.forestGreen)),
              )).toList(),
            ),
          ],

          // Requirements
          if (contract.requirements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Requirements', style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            ...contract.requirements.map((r) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(r, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary))),
                ],
              ),
            )),
          ],

          const SizedBox(height: AppSpacing.md),

          // Action row
          Row(
            children: [
              if (daysLeft > 0)
                Text(
                  'Deadline: ${DateFormat('dd MMM yyyy').format(contract.deadline)} ($daysLeft days)',
                  style: AppTextStyles.labelSm.copyWith(
                    color: daysLeft < 14 ? Colors.redAccent : AppColors.textSecondary,
                  ),
                ),
              const Spacer(),
              if (contract.status == 'open')
                FilledButton(
                  onPressed: () => ref.read(contractsProvider.notifier).applyForContract(contract.id),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Apply'),
                ),
              if (contract.status == 'applied')
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Applied ✓'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.borderLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Benefits card ---
class _BenefitsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.earthBrown.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.earthBrown.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why Contract Farming?', style: AppTextStyles.h4.copyWith(color: AppColors.earthBrown)),
          const SizedBox(height: AppSpacing.sm),
          _BenefitRow(icon: Icons.verified_rounded, text: 'Guaranteed market — no post-harvest losses'),
          _BenefitRow(icon: Icons.handshake_rounded, text: 'Input support — seed, fertilizer, chemicals provided'),
          _BenefitRow(icon: Icons.school_rounded, text: 'Technical support and extension services'),
          _BenefitRow(icon: Icons.trending_up_rounded, text: 'Fixed prices — protection from market volatility'),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.earthBrown),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
