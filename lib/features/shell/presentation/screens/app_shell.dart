import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';

class AppShell extends StatelessWidget {
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

  void _navigate(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/marketplace');
      case 2:
        context.go('/financing');
      case 3:
        context.go('/services');
      case 4:
        context.go('/expert');
      case 5:
        context.go('/profile');
    }
  }

  Widget _buildDrawer(BuildContext context, int currentIndex) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Row(
                children: [
                  const _AppLogo(size: 36),
                  const SizedBox(width: 12),
                  const Text(
                    'Transfarmation',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: currentIndex == 0,
              onTap: () {
                Navigator.pop(context); // Close drawer
                _navigate(context, 0);
              },
            ),
            _DrawerItem(
              icon: Icons.storefront_rounded,
              label: 'Markets',
              isSelected: currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                _navigate(context, 1);
              },
            ),
            _DrawerItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Loans',
              isSelected: currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                _navigate(context, 2);
              },
            ),
            _DrawerItem(
              icon: Icons.apps_rounded,
              label: 'Services',
              isSelected: currentIndex == 3,
              onTap: () {
                Navigator.pop(context);
                _navigate(context, 3);
              },
            ),
            _DrawerItem(
              icon: Icons.support_agent_rounded,
              label: 'Advisory',
              isSelected: currentIndex == 4,
              onTap: () {
                Navigator.pop(context);
                _navigate(context, 4);
              },
            ),
            const Spacer(),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: currentIndex == 5,
              onTap: () {
                Navigator.pop(context);
                _navigate(context, 5);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    final extended = context.isDesktop;

    if (!extended) {
      // Mobile / Tablet: Drawer with AppBar and BottomNavigationBar
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Transfarmation',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: AppColors.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
        drawer: _buildDrawer(context, currentIndex),
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: [0, 1, 2].contains(currentIndex) 
              ? currentIndex 
              : (currentIndex == 5 ? 3 : 0),
          onDestinationSelected: (idx) {
            if (idx == 0) _navigate(context, 0);
            else if (idx == 1) _navigate(context, 1);
            else if (idx == 2) _navigate(context, 2);
            else if (idx == 3) _navigate(context, 5);
          },
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primarySurface,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Markets',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Finance',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    // Desktop: Split view with Rail
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => _navigate(context, i),
            extended: true,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primarySurface,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AppLogo(size: 36),
                  SizedBox(width: 10),
                  Text(
                    'Transfarmation',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: Text('Markets'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                label: Text('Loans'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.apps_rounded),
                selectedIcon: Icon(Icons.apps_rounded),
                label: Text('Services'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.support_agent_outlined),
                selectedIcon: Icon(Icons.support_agent_rounded),
                label: Text('Advisory'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  final double size;
  const _AppLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(Icons.eco_rounded, color: Colors.white, size: size * 0.6),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontFamily: 'Poppins',
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primarySurface,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
    );
  }
}
