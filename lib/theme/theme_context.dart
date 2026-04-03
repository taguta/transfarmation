import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Convenience extension on [BuildContext] for quick access to
/// theme-aware colors without manual `isDark` ternaries everywhere.
///
/// Usage:
/// ```dart
/// final t = context.t;
/// Container(
///   color: t.surface,
///   child: Text('Hello', style: TextStyle(color: t.textPrimary)),
/// );
/// ```
extension ThemeContext on BuildContext {
  /// Quick access to the full [ThemeColors] resolver.
  ThemeColors get t => ThemeColors.of(this);

  /// Shortcut — is the current theme dark?
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// A resolved bag of theme-dependent colors.
///
/// Eliminates repetitive `isDark ? X : Y` ternaries across the codebase.
/// All values react to the current theme brightness.
class ThemeColors {
  final bool isDark;

  // ── Text ──
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // ── Surfaces ──
  final Color surface;
  final Color surfaceElevated;
  final Color background;

  // ── Borders ──
  final Color border;
  final Color divider;

  const ThemeColors._({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.surface,
    required this.surfaceElevated,
    required this.background,
    required this.border,
    required this.divider,
  });

  factory ThemeColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return ThemeColors._(
        isDark: true,
        textPrimary: AppColors.textOnDark,
        textSecondary: AppColors.textOnDark.withValues(alpha: 0.7),
        textTertiary: AppColors.textOnDark.withValues(alpha: 0.4),
        surface: AppColors.surfaceDark,
        surfaceElevated: AppColors.surfaceElevatedDark,
        background: AppColors.backgroundDark,
        border: AppColors.dividerDark,
        divider: AppColors.dividerDark,
      );
    }
    return const ThemeColors._(
      isDark: false,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textTertiary: AppColors.textTertiary,
      surface: AppColors.surface,
      surfaceElevated: AppColors.surfaceElevated,
      background: AppColors.background,
      border: AppColors.border,
      divider: AppColors.divider,
    );
  }
}
