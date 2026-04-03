import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: AppSpacing.xxl),

              // Sync status banner
              _buildSyncBanner(),
              const SizedBox(height: AppSpacing.xxl),

              // Quick stats
              _buildQuickStats(),
              const SizedBox(height: AppSpacing.xxl),

              // Quick actions
              Text(
                'Quick Actions',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.xxl),

              // Active loans
              _buildSectionHeader(
                'My Loans',
                onSeeAll: () => context.go('/financing'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildLoanCard(),
              const SizedBox(height: AppSpacing.xxl),

              // Market prices
              _buildSectionHeader(
                'Market Prices',
                onSeeAll: () => context.go('/marketplace'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildMarketPrices(),
              const SizedBox(height: AppSpacing.xxl),

              // Crop advisory
              _buildSectionHeader('Advisory', onSeeAll: () {}),
              const SizedBox(height: AppSpacing.md),
              _buildAdvisoryCard(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning 🌾',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tendai Moyo',
                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        // Notification bell
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/notifications'),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_done_outlined, color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'All data synced',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.success),
            ),
          ),
          Text(
            '2 min ago',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _StatCard(
          icon: Icons.landscape_rounded,
          label: 'Farm Size',
          value: '12 ha',
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        _StatCard(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Active Loans',
          value: '\$2,400',
          color: AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.md),
        _StatCard(
          icon: Icons.trending_up_rounded,
          label: 'Credit Score',
          value: '72',
          color: AppColors.marketplace,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            _ActionTile(
              icon: Icons.add_card_rounded,
              label: 'Apply\nLoan',
              color: AppColors.financing,
              onTap: () => context.go('/financing/apply'),
            ),
            _ActionTile(
              icon: Icons.sell_outlined,
              label: 'Sell\nProduce',
              color: AppColors.marketplace,
              onTap: () => context.go('/marketplace/sell'),
            ),
            _ActionTile(
              icon: Icons.landscape_rounded,
              label: 'My\nFarm',
              color: AppColors.primary,
              onTap: () => context.go('/farm'),
            ),
            _ActionTile(
              icon: Icons.support_agent_rounded,
              label: 'Ask\nExpert',
              color: AppColors.advisory,
              onTap: () => context.go('/expert'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            _ActionTile(
              icon: Icons.menu_book_rounded,
              label: 'Knowledge\nBase',
              color: AppColors.forestGreen,
              onTap: () => context.go('/knowledge'),
            ),
            _ActionTile(
              icon: Icons.cloud_rounded,
              label: 'Weather\nAlerts',
              color: Colors.blue,
              onTap: () => context.go('/weather'),
            ),
            _ActionTile(
              icon: Icons.camera_alt_rounded,
              label: 'AI\nDiagnosis',
              color: Colors.deepOrange,
              onTap: () => context.go('/diagnosis'),
            ),
            _ActionTile(
              icon: Icons.trending_up_rounded,
              label: 'Market\nPrices',
              color: AppColors.harvestGold,
              onTap: () => context.go('/market-prices'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See All',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildLoanCard() {
    return Container(
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
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maize Input Loan',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'AgriFinance ZW',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Active',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LoanDetail(label: 'Amount', value: '\$1,200'),
              _LoanDetail(label: 'Paid', value: '\$480'),
              _LoanDetail(label: 'Due', value: 'Jun 2026'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: 0.4,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '40% repaid',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketPrices() {
    final prices = [
      ('Maize', '\$280/ton', Icons.grass_rounded, 2.4),
      ('Tobacco', '\$3.20/kg', Icons.eco_rounded, -1.1),
      ('Soya', '\$520/ton', Icons.grain_rounded, 5.2),
    ];

    return Row(
      children:
          prices.map((p) {
            final isUp = p.$4 > 0;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: p != prices.last ? AppSpacing.md : 0,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(p.$3, color: AppColors.primary, size: 20),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      p.$1,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.$2,
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isUp ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: isUp ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${isUp ? '+' : ''}${p.$4}%',
                          style: AppTextStyles.caption.copyWith(
                            color: isUp ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildAdvisoryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌧️ Rain Expected',
                  style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Good time to apply top-dressing fertilizer on your maize crop.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _LoanDetail extends StatelessWidget {
  final String label;
  final String value;

  const _LoanDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
        Text(
          value,
          style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
