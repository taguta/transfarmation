import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Color-blind friendly mode for Colours.
/// Provides alternative color palettes optimized for three major
/// types of color vision deficiency:
/// - Protanopia (red-blind)
/// - Deuteranopia (green-blind)
/// - Tritanopia (blue-blind)
///
/// Fashion is inherently visual — we ensure ALL users can enjoy
/// outfit recommendations with proper color labeling and patterns.
enum ColorBlindMode {
  none,
  protanopia, // Red-blind (~1% male, ~0.01% female)
  deuteranopia, // Green-blind (~1% male, ~0.01% female)
  tritanopia, // Blue-blind (~0.003% of population)
}

class ColorBlindPalette {
  /// Colors optimized for each color-blind type.
  /// Uses Wong (2011) color-blind friendly palette as base.
  static const Map<ColorBlindMode, ColorBlindColors> palettes = {
    ColorBlindMode.none: ColorBlindColors(
      primary: Color(0xFFD4A373),
      secondary: Color(0xFF6B4E3D),
      accent: Color(0xFFE07A5F),
      success: Color(0xFF2D6A4F),
      warning: Color(0xFFF4A261),
      error: Color(0xFFE63946),
      heart: Color(0xFFE63946),
      fire: Color(0xFFFF6B35),
      crown: Color(0xFFFFD700),
      star: Color(0xFF9B5DE5),
      clap: Color(0xFF00BBF9),
    ),
    ColorBlindMode.protanopia: ColorBlindColors(
      primary: Color(0xFFCC9933), // Golden yellow (safe)
      secondary: Color(0xFF555555), // Dark grey
      accent: Color(0xFF0072B2), // Blue (clearly distinguishable)
      success: Color(0xFF0072B2), // Blue replaces green
      warning: Color(0xFFE69F00), // Orange-yellow
      error: Color(0xFF000000), // Black with icon indicator
      heart: Color(0xFFCC79A7), // Pink-purple
      fire: Color(0xFFE69F00), // Orange-yellow
      crown: Color(0xFFF0E442), // Yellow
      star: Color(0xFF0072B2), // Blue
      clap: Color(0xFF56B4E9), // Sky blue
    ),
    ColorBlindMode.deuteranopia: ColorBlindColors(
      primary: Color(0xFFCC9933),
      secondary: Color(0xFF555555),
      accent: Color(0xFF0072B2),
      success: Color(0xFF0072B2),
      warning: Color(0xFFE69F00),
      error: Color(0xFF000000),
      heart: Color(0xFFCC79A7),
      fire: Color(0xFFE69F00),
      crown: Color(0xFFF0E442),
      star: Color(0xFF0072B2),
      clap: Color(0xFF56B4E9),
    ),
    ColorBlindMode.tritanopia: ColorBlindColors(
      primary: Color(0xFFD4A373),
      secondary: Color(0xFF6B4E3D),
      accent: Color(0xFFE63946), // Red (clearly visible)
      success: Color(0xFF009E73), // Teal-green
      warning: Color(0xFFD55E00), // Vermillion
      error: Color(0xFFE63946),
      heart: Color(0xFFE63946),
      fire: Color(0xFFD55E00),
      crown: Color(0xFFE69F00),
      star: Color(0xFFE63946),
      clap: Color(0xFF009E73),
    ),
  };

  static ColorBlindColors forMode(ColorBlindMode mode) {
    return palettes[mode]!;
  }
}

class ColorBlindColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color heart;
  final Color fire;
  final Color crown;
  final Color star;
  final Color clap;

  const ColorBlindColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.heart,
    required this.fire,
    required this.crown,
    required this.star,
    required this.clap,
  });
}

/// Additional accessibility features for color-blind users in fashion context
class FashionAccessibility {
  /// Text labels for colors — essential when color swatches aren't sufficient
  static const Map<String, String> colorDescriptions = {
    'red': 'Red (warm, bold)',
    'blue': 'Blue (cool, calm)',
    'green': 'Green (natural, fresh)',
    'yellow': 'Yellow (bright, cheerful)',
    'orange': 'Orange (warm, energetic)',
    'purple': 'Purple (regal, creative)',
    'pink': 'Pink (soft, playful)',
    'black': 'Black (classic, sleek)',
    'white': 'White (clean, crisp)',
    'brown': 'Brown (earthy, warm)',
    'grey': 'Grey (neutral, versatile)',
    'navy': 'Navy (deep, professional)',
    'beige': 'Beige (neutral, soft)',
    'cream': 'Cream (warm white)',
    'burgundy': 'Burgundy (deep red-purple)',
    'teal': 'Teal (blue-green mix)',
    'olive': 'Olive (dark yellow-green)',
    'coral': 'Coral (pink-orange mix)',
    'maroon': 'Maroon (dark red-brown)',
    'lavender': 'Lavender (light purple)',
  };

  /// Pattern indicators for swatches (when color alone isn't enough)
  /// These patterns overlay on color swatches to distinguish them
  static const Map<String, String> patternIndicators = {
    'available': '●', // Filled circle
    'laundry': '◐', // Half circle
    'storage': '○', // Empty circle
    'lent': '◑', // Other half
    'damaged': '✕', // Cross
  };

  /// Get a swatch widget description that includes both color name and visual pattern
  static String accessibleColorLabel(String colorName, {bool showHex = false}) {
    final desc = colorDescriptions[colorName.toLowerCase()];
    return desc ?? colorName;
  }
}

/// Notifier for color-blind mode setting
class ColorBlindModeNotifier extends Notifier<ColorBlindMode> {
  @override
  ColorBlindMode build() => ColorBlindMode.none;

  void setMode(ColorBlindMode mode) => state = mode;
}

/// Provider for color-blind mode setting
final colorBlindModeProvider =
    NotifierProvider<ColorBlindModeNotifier, ColorBlindMode>(ColorBlindModeNotifier.new);

/// Provider for current color palette (reactive to mode changes)
final colorPaletteProvider = Provider<ColorBlindColors>((ref) {
  final mode = ref.watch(colorBlindModeProvider);
  return ColorBlindPalette.forMode(mode);
});

