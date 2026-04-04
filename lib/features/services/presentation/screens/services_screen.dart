import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => context.go('/home'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'All Services',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Everything you need for your farming journey',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              _SectionHeader(title: 'Knowledge & Learning'),
              const SizedBox(height: AppSpacing.md),
              _ServiceTile(
                icon: Icons.menu_book_rounded,
                title: 'Knowledge Base',
                subtitle: 'Crop & livestock guides, pest identification',
                color: AppColors.forestGreen,
                onTap: () => context.go('/knowledge'),
              ),
              _ServiceTile(
                icon: Icons.support_agent_rounded,
                title: 'Expert Network',
                subtitle: 'Chat with agronomists and vet specialists',
                color: AppColors.advisory,
                onTap: () => context.go('/expert'),
              ),
              _ServiceTile(
                icon: Icons.forum_rounded,
                title: 'Farmer Community',
                subtitle: 'Discuss tips, alerts, and market news with locals',
                color: AppColors.primary,
                onTap: () => context.go('/community'),
              ),
              _ServiceTile(
                icon: Icons.camera_alt_rounded,
                title: 'AI Diagnosis',
                subtitle: 'Snap a photo to identify crop & livestock diseases',
                color: Colors.deepOrange,
                onTap: () => context.go('/diagnosis'),
              ),

              const SizedBox(height: AppSpacing.xxl),

              _SectionHeader(title: 'Farm Management'),
              const SizedBox(height: AppSpacing.md),
              _ServiceTile(
                icon: Icons.landscape_rounded,
                title: 'Farm Records',
                subtitle: 'Track fields, livestock, expenses & GPS boundaries',
                color: AppColors.primary,
                onTap: () => context.go('/farm-records'),
              ),
              _ServiceTile(
                icon: Icons.cloud_rounded,
                title: 'Weather & Calendar',
                subtitle: 'Alerts, 7-day forecast & seasonal planting calendar',
                color: Colors.blue,
                onTap: () => context.go('/weather'),
              ),
              _ServiceTile(
                icon: Icons.people_outline_rounded,
                title: 'Labor & Tasks',
                subtitle: 'Manage farm workers and daily assignments',
                color: AppColors.error,
                onTap: () => context.go('/labor-management'),
              ),
              _ServiceTile(
                icon: Icons.sensors_rounded,
                title: 'IoT & Sensors',
                subtitle: 'Live telemetry from smart farm hardware',
                color: AppColors.success,
                onTap: () => context.go('/iot-dashboard'),
              ),

              const SizedBox(height: AppSpacing.xxl),

              _SectionHeader(title: 'Marketplace & Inputs'),
              const SizedBox(height: AppSpacing.md),
              _ServiceTile(
                icon: Icons.storefront_rounded,
                title: 'Produce Marketplace',
                subtitle: 'Buy and sell agricultural produce',
                color: AppColors.marketplace,
                onTap: () => context.go('/marketplace'),
              ),
              _ServiceTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Traceability & QR',
                subtitle: 'Generate verifiable QR codes for farm produce',
                color: AppColors.forestGreen,
                onTap: () => context.go('/traceability'),
              ),
              _ServiceTile(
                icon: Icons.store_rounded,
                title: 'Farm Inputs',
                subtitle: 'Seeds, fertilizers, chemicals & equipment',
                color: AppColors.marketplace,
                onTap: () => context.go('/inputs'),
              ),
              _ServiceTile(
                icon: Icons.trending_up_rounded,
                title: 'Market Prices',
                subtitle: 'Real-time commodity prices & where to sell',
                color: AppColors.harvestGold,
                onTap: () => context.go('/market-prices'),
              ),
              _ServiceTile(
                icon: Icons.card_giftcard_rounded,
                title: 'Subsidy Tracking',
                subtitle: 'Government & NGO subsidy programs',
                color: AppColors.info,
                onTap: () => context.go('/inputs/subsidies'),
              ),

              const SizedBox(height: AppSpacing.xxl),

              _SectionHeader(title: 'Finance & Savings'),
              const SizedBox(height: AppSpacing.md),
              _ServiceTile(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Financing',
                subtitle: 'Apply for loans, track repayments',
                color: AppColors.financing,
                onTap: () => context.go('/financing'),
              ),
              _ServiceTile(
                icon: Icons.group_rounded,
                title: 'Savings Groups (Mukando)',
                subtitle: 'Rotating savings with your farming community',
                color: AppColors.primary,
                onTap: () => context.go('/savings'),
              ),

              const SizedBox(height: AppSpacing.xxl),

              _SectionHeader(title: 'Cooperatives & Contracts'),
              const SizedBox(height: AppSpacing.md),
              _ServiceTile(
                icon: Icons.shopping_cart_rounded,
                title: 'Group Buying',
                subtitle: 'Bulk input purchases with your cooperative',
                color: AppColors.advisory,
                onTap: () => context.go('/group-buying'),
              ),
              _ServiceTile(
                icon: Icons.handshake_rounded,
                title: 'Contract Farming',
                subtitle: 'Guaranteed markets with buyer input support',
                color: AppColors.earthBrown,
                onTap: () => context.go('/contracts'),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
      ),
    );
  }
}
