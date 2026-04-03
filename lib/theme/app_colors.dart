import 'package:flutter/material.dart';

/// Transfarmation brand colors — Agriculture, Farming & Financing.
///
/// Palette philosophy:
///   • Forest Green (#2E7D32) — growth, agriculture, trust
///   • Harvest Gold (#F9A825) — prosperity, financing, warmth
///   • Earth Brown (#795548) — soil, grounding, reliability
///   • Warm Cream (#FAFAF5) — natural light surfaces
///   • Deep Forest (#1B2E1B) — dark mode base
abstract final class AppColors {
  // ─── Primary Brand (Forest Green) ────────────────────────────
  static const Color primary = Color(0xFF2E7D32);        // Forest green
  static const Color primaryLight = Color(0xFF60AD5E);    // Fresh leaf green
  static const Color primaryDark = Color(0xFF005005);     // Deep forest
  static const Color primarySurface = Color(0xFFE8F5E9);  // Mint wash

  // ─── Secondary / Financing (Harvest Gold) ───────────────────
  static const Color accent = Color(0xFFF9A825);          // Harvest gold
  static const Color accentLight = Color(0xFFFFD95A);     // Sun gold
  static const Color accentSurface = Color(0xFFFFF8E1);   // Cream gold

  static const Color secondary = Color(0xFF795548);       // Earth brown
  static const Color secondaryLight = Color(0xFFA98274);   // Warm clay
  static const Color secondarySurface = Color(0xFFEFEBE9); // Soft earth

  // ─── Neutrals / Surfaces ─────────────────────────────────────
  static const Color background = Color(0xFFFAFAF5);      // Warm cream
  static const Color backgroundDark = Color(0xFF1B2E1B);   // Deep forest
  static const Color surface = Color(0xFFFFFFFF);          // Pure white
  static const Color surfaceElevated = Color(0xFFF5F5F0);  // Warm gray
  static const Color surfaceDark = Color(0xFF243524);       // Forest panel
  static const Color surfaceElevatedDark = Color(0xFF2D4A2D); // Elevated forest

  // ─── Text ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1B3A1B);      // Dark forest text
  static const Color textSecondary = Color(0xFF5D7B5D);    // Muted green-gray
  static const Color textTertiary = Color(0xFF94A894);     // Light sage
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFE8F5E9);       // Mint white

  // ─── Borders & Dividers ──────────────────────────────────────
  static const Color border = Color(0xFFD5DDD5);           // Soft sage border
  static const Color borderStrong = Color(0xFFB0BEB0);     // Stronger sage
  static const Color divider = Color(0xFFD5DDD5);
  static const Color dividerDark = Color(0xFF3A5C3A);      // Dark forest divider

  // ─── Status Colors ───────────────────────────────────────────
  static const Color success = Color(0xFF43A047);          // Vibrant green
  static const Color successSurface = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFA726);          // Warm amber
  static const Color warningSurface = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);            // Alert red
  static const Color errorSurface = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF039BE5);             // Sky blue
  static const Color infoSurface = Color(0xFFE1F5FE);

  // ─── Loan Status Colors ──────────────────────────────────────
  static const Color loanPending = Color(0xFFFFA726);      // Amber
  static const Color loanApproved = Color(0xFF43A047);     // Green
  static const Color loanRejected = Color(0xFFE53935);     // Red
  static const Color loanDraft = Color(0xFF78909C);        // Gray-blue
  static const Color loanDisbursed = Color(0xFF00897B);    // Teal

  // ─── Feature Accent Colors ──────────────────────────────────
  static const Color financing = Color(0xFFF9A825);        // Gold
  static const Color marketplace = Color(0xFF00897B);      // Teal
  static const Color advisory = Color(0xFF5C6BC0);         // Indigo
  static const Color veterinary = Color(0xFFEF6C00);       // Deep orange

  // ─── Semantic Aliases ───────────────────────────────────────
  static const Color forestGreen = primary;                 // #2E7D32
  static const Color harvestGold = accent;                  // #F9A825
  static const Color earthBrown = secondary;                // #795548
  static const Color borderLight = border;                  // Soft sage border

  // ─── Gradients ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF2E7D32), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFD95A), Color(0xFFF9A825)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFAFAF5), Color(0xFFF5F5F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1B2E1B), Color(0xFF243524)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient financingGradient = LinearGradient(
    colors: [Color(0xFFF9A825), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunriseGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFFF9A825)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ─── Glassmorphism ──────────────────────────────────────────
  static Color get glassLight => const Color(0xFFFFFFFF).withValues(alpha: 0.92);
  static Color get glassDark => const Color(0xFF1B2E1B).withValues(alpha: 0.92);
  static Color get glassBorderLight => const Color(0xFFD5DDD5).withValues(alpha: 0.60);
  static Color get glassBorderDark => const Color(0xFFFFFFFF).withValues(alpha: 0.08);

  // ─── Shadows ────────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: const Color(0xFF1B3A1B).withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0xFF1B3A1B).withValues(alpha: 0.06),
      blurRadius: 10,
      offset: const Offset(0, 2),
      spreadRadius: -1,
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: const Color(0xFF1B3A1B).withValues(alpha: 0.10),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> get shadowGold => [
    BoxShadow(
      color: primary.withValues(alpha: 0.20),
      blurRadius: 12,
      offset: const Offset(0, 3),
      spreadRadius: -2,
    ),
  ];
}
