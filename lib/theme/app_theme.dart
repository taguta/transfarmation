import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Typography scale — Poppins throughout.
abstract final class AppTextStyles {
  // Display
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
  );
  static const TextStyle displaySm = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.15,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
  );

  // Body
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.6,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.55,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // Label
  static const TextStyle labelLg = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.4,
  );
  static const TextStyle labelMd = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.4,
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Caption / overline
  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.45,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.4,
  );
}

/// Consistent spacing values.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  static const double massive = 64;
}

/// Border radius tokens.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;
}

abstract final class AppTheme {
  // ─── Light Theme (White + Dark Blue accents) ─────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primarySurface,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.secondarySurface,
          onSecondaryContainer: AppColors.textPrimary,
          tertiary: AppColors.accent,
          onTertiary: Colors.white,
          tertiaryContainer: AppColors.accentSurface,
          onTertiaryContainer: AppColors.primaryDark,
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorSurface,
          onErrorContainer: const Color(0xFF7A0021),
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surfaceElevated,
          outline: AppColors.border,
          outlineVariant: AppColors.divider,
          shadow: const Color(0x0A0A1929),
          scrim: const Color(0x800A1929),
          inverseSurface: AppColors.textPrimary,
          onInverseSurface: AppColors.background,
          inversePrimary: AppColors.primaryLight,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.background,

        // ── AppBar ──
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          surfaceTintColor: Colors.transparent,
        ),

        // ── Cards ──
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── Inputs ──
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textTertiary),
          labelStyle: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary),
        ),

        // ── Elevated Buttons (solid blue, pill shape) ──
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            textStyle: AppTextStyles.labelLg.copyWith(inherit: false),
          ),
        ),

        // ── Filled Buttons ──
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            textStyle: AppTextStyles.labelLg.copyWith(inherit: false),
          ),
        ),

        // ── Outlined Buttons ──
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border, width: 1),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            textStyle: AppTextStyles.labelLg.copyWith(inherit: false),
          ),
        ),

        // ── Text Buttons ──
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            textStyle: AppTextStyles.labelLg.copyWith(inherit: false),
          ),
        ),

        // ── Chips ──
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primarySurface,
          labelStyle: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            side: const BorderSide(color: AppColors.border),
          ),
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        ),

        // ── Dialogs ──
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          contentTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),

        // ── Bottom Sheet ──
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          modalElevation: 0,
          modalBackgroundColor: AppColors.surface,
          dragHandleColor: AppColors.border,
          showDragHandle: true,
        ),

        // ── ListTile ──
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),

        // ── SnackBar ──
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textOnPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),

        // ── Divider ──
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 0,
        ),

        // ── Icon ──
        iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
        primaryIconTheme: const IconThemeData(color: AppColors.primary, size: 22),

        // ── Text ──
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLg.copyWith(color: AppColors.textPrimary),
          displaySmall: AppTextStyles.displaySm.copyWith(color: AppColors.textPrimary),
          headlineLarge: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
          headlineMedium: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          headlineSmall: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          titleLarge: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          titleMedium: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          titleSmall: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary),
          bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.textPrimary),
          bodyMedium: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
          bodySmall: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          labelLarge: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary),
          labelMedium: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary),
          labelSmall: AppTextStyles.labelSm.copyWith(color: AppColors.textTertiary),
        ),
      );

  // ─── Dark Theme (Deep Navy + Bright Blue) ────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primaryLight,
          onPrimary: AppColors.backgroundDark,
          primaryContainer: AppColors.primaryDark.withValues(alpha: 0.4),
          onPrimaryContainer: AppColors.primaryLight,
          secondary: AppColors.secondaryLight,
          onSecondary: AppColors.backgroundDark,
          secondaryContainer: AppColors.secondary.withValues(alpha: 0.25),
          onSecondaryContainer: AppColors.secondaryLight,
          tertiary: AppColors.accentLight,
          onTertiary: AppColors.backgroundDark,
          tertiaryContainer: AppColors.accent.withValues(alpha: 0.25),
          onTertiaryContainer: AppColors.accentLight,
          error: const Color(0xFFEF9A9A),
          onError: AppColors.backgroundDark,
          errorContainer: AppColors.error.withValues(alpha: 0.25),
          onErrorContainer: const Color(0xFFFFCDD2),
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textOnDark,
          surfaceContainerHighest: AppColors.surfaceElevatedDark,
          outline: AppColors.dividerDark,
          outlineVariant: AppColors.dividerDark.withValues(alpha: 0.5),
          shadow: const Color(0x40000000),
          scrim: const Color(0x99000000),
          inverseSurface: AppColors.textOnDark,
          onInverseSurface: AppColors.backgroundDark,
          inversePrimary: AppColors.primaryDark,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.backgroundDark,

        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.backgroundDark,
          foregroundColor: AppColors.textOnDark,
          titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.textOnDark),
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          surfaceTintColor: Colors.transparent,
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surfaceDark,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: AppColors.dividerDark, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceElevatedDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: AppColors.dividerDark, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: AppColors.dividerDark, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          hintStyle: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.4),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.backgroundDark,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            textStyle: AppTextStyles.labelLg.copyWith(inherit: false),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.backgroundDark,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            textStyle: AppTextStyles.labelLg.copyWith(inherit: false),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            side: BorderSide(color: AppColors.dividerDark, width: 1),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            textStyle: AppTextStyles.labelLg.copyWith(inherit: false),
          ),
        ),

        // ── Text Buttons (dark) ──
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            textStyle: AppTextStyles.labelLg.copyWith(inherit: false),
          ),
        ),

        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceElevatedDark,
          selectedColor: AppColors.primaryDark.withValues(alpha: 0.5),
          labelStyle: AppTextStyles.labelMd.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            side: BorderSide(color: AppColors.dividerDark),
          ),
          side: BorderSide(color: AppColors.dividerDark),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceDark,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.textOnDark),
          contentTextStyle: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.7),
          ),
        ),

        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.surfaceDark,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          dragHandleColor: AppColors.dividerDark,
          showDragHandle: true,
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceElevatedDark,
          contentTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textOnDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
          space: 0,
        ),

        iconTheme: IconThemeData(
          color: AppColors.textOnDark.withValues(alpha: 0.6),
          size: 22,
        ),
        primaryIconTheme: const IconThemeData(color: AppColors.primaryLight, size: 22),

        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLg.copyWith(color: AppColors.textOnDark),
          displaySmall: AppTextStyles.displaySm.copyWith(color: AppColors.textOnDark),
          headlineLarge: AppTextStyles.h1.copyWith(color: AppColors.textOnDark),
          headlineMedium: AppTextStyles.h2.copyWith(color: AppColors.textOnDark),
          headlineSmall: AppTextStyles.h3.copyWith(color: AppColors.textOnDark),
          titleLarge: AppTextStyles.h3.copyWith(color: AppColors.textOnDark),
          titleMedium: AppTextStyles.h4.copyWith(color: AppColors.textOnDark),
          titleSmall: AppTextStyles.labelLg.copyWith(color: AppColors.textOnDark),
          bodyLarge: AppTextStyles.bodyLg.copyWith(color: AppColors.textOnDark),
          bodyMedium: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.85),
          ),
          bodySmall: AppTextStyles.bodySm.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.6),
          ),
          labelLarge: AppTextStyles.labelLg.copyWith(color: AppColors.textOnDark),
          labelMedium: AppTextStyles.labelMd.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.7),
          ),
          labelSmall: AppTextStyles.labelSm.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.5),
          ),
        ),
      );
}
