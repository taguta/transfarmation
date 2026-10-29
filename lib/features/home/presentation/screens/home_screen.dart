import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/home_live_widgets.dart';
import '../widgets/workspace_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = context.pagePadding;
    final userState = ref.watch(authStateProvider);
    final displayName = userState.valueOrNull?.displayName ?? 'New Farmer';

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          child: context.isDesktop
              ? _DesktopLayout(padding: padding, displayName: displayName)
              : _MobileTabletLayout(padding: padding, displayName: displayName),
        ),
      ),
    );
  }
}

// ── Desktop: two-pane layout ──────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final double padding;
  final String displayName;
  const _DesktopLayout({required this.padding, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main column
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, displayName),
                const SizedBox(height: AppSpacing.xxl),
                _buildSyncBanner(),
                const SizedBox(height: AppSpacing.xxl),
                _buildQuickStats(),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Quick Actions',
                  style: AppTextStyles.h3.copyWith(
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildQuickActions(context, columns: 6),
                const SizedBox(height: AppSpacing.xxl),
                _buildAdvisoryCard(),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),
          // Sidebar
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'My Loans',
                  onSeeAll: () => context.go('/financing'),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildLoanCard(),
                const SizedBox(height: AppSpacing.xxl),
                _buildSectionHeader(
                  'Market Prices',
                  onSeeAll: () => context.go('/marketplace'),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildMarketPricesSidebar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile / Tablet: single-column layout ─────────────────────────────────────

class _MobileTabletLayout extends StatelessWidget {
  final double padding;
  final String displayName;
  const _MobileTabletLayout({required this.padding, required this.displayName});

  @override
  Widget build(BuildContext context) {
    final columns = context.isTablet ? 4 : 3;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, displayName),
          const SizedBox(height: AppSpacing.xxl),
          _buildSyncBanner(),
          const SizedBox(height: AppSpacing.xxl),
          _buildQuickStats(),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Quick Actions',
            style: AppTextStyles.h3.copyWith(color: Palette.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildQuickActions(context, columns: columns),
          const SizedBox(height: AppSpacing.xxl),
          _buildSectionHeader(
            'My Loans',
            onSeeAll: () => context.go('/financing'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLoanCard(),
          const SizedBox(height: AppSpacing.xxl),
          _buildSectionHeader(
            'Market Prices',
            onSeeAll: () => context.go('/marketplace'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildMarketPrices(),
          const SizedBox(height: AppSpacing.xxl),
          _buildSectionHeader('Advisory', onSeeAll: () {}),
          const SizedBox(height: AppSpacing.md),
          _buildAdvisoryCard(),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ── Shared widget builders ────────────────────────────────────────────────────

Widget _buildHeader(BuildContext context, String displayName) =>
    WorkspaceHeader(displayName: displayName);

Widget _buildSyncBanner() => const HomeSyncBanner();

Widget _buildQuickStats() => const HomeStats();

Widget _buildQuickActions(BuildContext context, {required int columns}) =>
    WorkspaceActions(columns: columns);

Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: AppTextStyles.h3.copyWith(color: Palette.textPrimary),
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

Widget _buildLoanCard() => const ActiveLoanCard();

Widget _buildMarketPrices() => const HomeMarketPrices();

Widget _buildMarketPricesSidebar() => const HomeMarketPrices(vertical: true);

Widget _buildAdvisoryCard() => const HomeAdvisoryCard();
