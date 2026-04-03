import 'package:flutter/material.dart';

/// Breakpoint thresholds (Material Design 3 window size classes)
class Breakpoints {
  Breakpoints._();

  /// Compact → Medium boundary (phone → tablet)
  static const double tablet = 600;

  /// Medium → Expanded boundary (tablet → desktop/web)
  static const double desktop = 1200;

  /// Maximum content width for readable line lengths on large screens
  static const double maxContentWidth = 1280;

  /// Ideal form/card width on wide screens
  static const double formWidth = 480;
}

/// Categorised window size classes
enum ScreenSize { mobile, tablet, desktop }

/// Convenience extensions for responsive logic inside build methods.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w >= Breakpoints.desktop) return ScreenSize.desktop;
    if (w >= Breakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;

  /// True on tablet and desktop — useful for showing NavigationRail.
  bool get isTabletOrDesktop => !isMobile;

  /// Pick a value by current screen size; falls back to [mobile] when
  /// a wider-screen value is not provided.
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    switch (screenSize) {
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }

  /// Returns adaptive horizontal page padding.
  double get pagePadding => responsive<double>(mobile: 16, tablet: 24, desktop: 32);

  /// Returns adaptive cross-axis count for grids.
  int gridColumns({int mobile = 2, int tablet = 3, int desktop = 4}) =>
      responsive(mobile: mobile, tablet: tablet, desktop: desktop);
}

/// Constrains [child] to [maxWidth] and centres it horizontally,
/// preventing content from stretching to full screen width on desktop/web.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// A two-column layout for desktop: wide [main] content beside a fixed-width
/// [sidebar]. Falls back to [main] only on mobile/tablet.
class ResponsiveTwoPane extends StatelessWidget {
  final Widget main;
  final Widget sidebar;
  final double sidebarWidth;
  final double gap;

  const ResponsiveTwoPane({
    super.key,
    required this.main,
    required this.sidebar,
    this.sidebarWidth = 320,
    this.gap = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop) return main;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: main),
        SizedBox(width: gap),
        SizedBox(width: sidebarWidth, child: sidebar),
      ],
    );
  }
}
