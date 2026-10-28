import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/theme_provider.dart';
import '../../../../core/alerts/proactive_alerts.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../sync_ui/presentation/providers/sync_providers.dart';

/// Deep-forest tones used by the sidebar / rail in both light and dark mode.
const _forestTop = Color(0xFF0E1D10);
const _forestBottom = Color(0xFF1B3A1B);

class _Destination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _Destination(this.icon, this.selectedIcon, this.label, this.route);
}

const _destinations = <_Destination>[
  _Destination(Icons.home_outlined, Icons.home_rounded, 'Home', '/home'),
  _Destination(
    Icons.storefront_outlined,
    Icons.storefront_rounded,
    'Markets',
    '/marketplace',
  ),
  _Destination(
    Icons.account_balance_wallet_outlined,
    Icons.account_balance_wallet_rounded,
    'Loans',
    '/financing',
  ),
  _Destination(Icons.apps_outlined, Icons.apps_rounded, 'Services', '/services'),
  _Destination(
    Icons.support_agent_outlined,
    Icons.support_agent_rounded,
    'Advisory',
    '/expert',
  ),
  _Destination(
    Icons.person_outline_rounded,
    Icons.person_rounded,
    'Profile',
    '/profile',
  ),
];

/// Destinations shown in the mobile bottom bar (Profile lives in the top bar).
const _mobileDestinationCount = 5;

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static int _indexFromLocation(String location) {
    if (location.startsWith('/marketplace')) return 1;
    if (location.startsWith('/financing')) return 2;
    if (location.startsWith('/services')) return 3;
    if (location.startsWith('/expert')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0;
  }

  static void _navigate(BuildContext context, int i) =>
      context.go(_destinations[i].route);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    // Keeps weather and crop-stage alerts flowing into notifications.
    ref.watch(proactiveAlertsProvider);

    final syncQueue = ref.watch(syncItemsProvider);
    final pendingCount = syncQueue.valueOrNull?.length ?? 0;

    final topBar = _TopBar(
      title: _destinations[currentIndex].label,
      pendingCount: pendingCount,
    );

    final content = Expanded(
      child: ResponsiveCenter(
        maxWidth: context.isDesktop ? Breakpoints.maxContentWidth : 1100,
        child: child,
      ),
    );

    if (context.isMobile) {
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(children: [topBar, content]),
        ),
        bottomNavigationBar: _FloatingNavBar(
          currentIndex: currentIndex,
          onSelected: (i) => _navigate(context, i),
        ),
      );
    }

    final navigation = context.isDesktop
        ? _Sidebar(
            currentIndex: currentIndex,
            pendingCount: pendingCount,
            onSelected: (i) => _navigate(context, i),
          )
        : _CompactRail(
            currentIndex: currentIndex,
            onSelected: (i) => _navigate(context, i),
          );

    return Scaffold(
      body: Row(
        children: [
          navigation,
          Expanded(
            child: Column(children: [topBar, content]),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  final String title;
  final int pendingCount;

  const _TopBar({required this.title, required this.pendingCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mobile = context.isMobile;
    final unread = ref.watch(unreadCountProvider);
    // Rebuild when the theme mode changes so the toggle icon stays in sync.
    ref.watch(themeModeProvider);
    final fg = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 24),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.backgroundDark : AppColors.background)
            .withValues(alpha: 0.96),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          if (mobile) ...[
            const _AppLogo(size: 34),
            const SizedBox(width: 10),
            Text(
              'Transfarmation',
              style: AppTextStyles.h4.copyWith(
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else
            Text(title, style: AppTextStyles.h3.copyWith(color: fg)),
          const Spacer(),
          if (pendingCount > 0) ...[
            _SyncPill(pendingCount: pendingCount),
            const SizedBox(width: 8),
          ],
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () {
              final notifier = ref.read(themeModeProvider.notifier);
              isDark ? notifier.setLight() : notifier.setDark();
            },
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: fg,
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.go('/notifications'),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              backgroundColor: AppColors.accent,
              textColor: Colors.black,
              child: Icon(Icons.notifications_none_rounded, color: fg),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Profile',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.go('/profile'),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncPill extends StatelessWidget {
  final int pendingCount;

  const _SyncPill({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    final compact = context.isMobile;
    return Tooltip(
      message: 'Offline mode: $pendingCount items waiting to sync',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warningSurface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 14, color: Colors.orange.shade900),
            const SizedBox(width: 6),
            Text(
              compact ? '$pendingCount' : '$pendingCount waiting to sync',
              style: AppTextStyles.labelSm.copyWith(color: Colors.orange.shade900),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mobile: floating bottom bar ──────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _FloatingNavBar({required this.currentIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            ),
            boxShadow: AppColors.shadowLg,
          ),
          child: Row(
            children: [
              for (var i = 0; i < _mobileDestinationCount; i++)
                Expanded(
                  child: _FloatingNavItem(
                    destination: _destinations[i],
                    selected: currentIndex == i,
                    isDark: isDark,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final _Destination destination;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.destination,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final idle = isDark ? AppColors.textTertiary : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: selected ? AppColors.shadowGold : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 22,
                color: selected ? Colors.white : idle,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : idle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tablet: compact icon rail ────────────────────────────────────────────

class _CompactRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _CompactRail({required this.currentIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_forestTop, _forestBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            const _AppLogo(size: 42, glow: true),
            const SizedBox(height: 24),
            for (var i = 0; i < _destinations.length - 1; i++)
              _RailItem(
                destination: _destinations[i],
                selected: currentIndex == i,
                onTap: () => onSelected(i),
              ),
            const Spacer(),
            _RailItem(
              destination: _destinations.last,
              selected: currentIndex == _destinations.length - 1,
              onTap: () => onSelected(_destinations.length - 1),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  const _RailItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          hoverColor: Colors.white.withValues(alpha: 0.06),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 62,
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 24,
                  color: selected
                      ? Colors.white
                      : AppColors.textOnDark.withValues(alpha: 0.65),
                ),
                const SizedBox(height: 3),
                Text(
                  destination.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : AppColors.textOnDark.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Desktop: full sidebar ────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final int currentIndex;
  final int pendingCount;
  final ValueChanged<int> onSelected;

  const _Sidebar({
    required this.currentIndex,
    required this.pendingCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 268,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_forestTop, _forestBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Soft glow behind the brand block.
          Positioned(
            top: -90,
            left: -90,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _AppLogo(size: 40, glow: true),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Transfarmation',
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'People busy transforming their farming activities',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnDark.withValues(alpha: 0.55),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    'MENU',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textOnDark.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                for (var i = 0; i < _destinations.length - 1; i++)
                  _SidebarItem(
                    destination: _destinations[i],
                    selected: currentIndex == i,
                    onTap: () => onSelected(i),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SyncStatusCard(pendingCount: pendingCount),
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  destination: _destinations.last,
                  selected: currentIndex == _destinations.length - 1,
                  onTap: () => onSelected(_destinations.length - 1),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? Colors.white
        : AppColors.textOnDark.withValues(alpha: 0.72);

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          hoverColor: Colors.white.withValues(alpha: 0.06),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 22,
                  color: fg,
                ),
                const SizedBox(width: 14),
                Text(
                  destination.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  final int pendingCount;

  const _SyncStatusCard({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    final synced = pendingCount == 0;
    final dot = synced ? AppColors.primaryLight : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dot,
              boxShadow: [
                BoxShadow(color: dot.withValues(alpha: 0.6), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  synced ? 'All data synced' : 'Offline mode',
                  style: AppTextStyles.labelMd.copyWith(color: Colors.white),
                ),
                Text(
                  synced ? 'Up to date' : '$pendingCount items waiting to sync',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnDark.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  final double size;
  final bool glow;

  const _AppLogo({required this.size, this.glow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Icon(Icons.eco_rounded, color: Colors.white, size: size * 0.58),
    );
  }
}
