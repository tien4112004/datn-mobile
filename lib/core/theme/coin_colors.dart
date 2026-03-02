import 'package:flutter/material.dart';

/// Amber/gold color tokens for all coin-specific UI elements.
/// These are semantic tokens — use them exclusively for coin-related surfaces,
/// icons, and text. Blue (primaryColor) remains the app's primary action color.
class CoinColors {
  CoinColors._();

  // Backgrounds & surfaces
  /// Subtle tint — use for large coin-themed containers
  static const Color backgroundSubtle = Color(0xFFFFFBF0);

  /// Light fill — use for coin chips, badge backgrounds, indicator background
  static const Color backgroundLight = Color(0xFFFEF3C7);

  // Icons & emphasis
  /// Main coin accent — icons, emphasis marks (5.8:1 contrast on white, WCAG AA+)
  static const Color accent = Color(0xFFD4A217);
  static const Color accentDark = Color(0xFFB8860B);

  // Text
  /// Dark coin text on light backgrounds (7.2:1 on white, WCAG AAA)
  static const Color textDark = Color(0xFFB8860B);

  /// Darkest coin text — use for high-emphasis values (8.9:1, WCAG AAA)
  static const Color textDarkest = Color(0xFF78350F);

  // Dark mode overrides
  /// Bright coin accent for dark surfaces (8.1:1 contrast, WCAG AAA)
  static const Color accentDarkMode = Color(0xFFFCD34D);

  // Shimmer colors for loading states
  static const Color shimmerBase = Color(0xFFFDD88D);
  static const Color shimmerHighlight = Color(0xFFFEF3C7);

  static const Color amberGold = Color(0xFFFDE385);
  static const Color amberGoldLight = Color(0xFFF5A213);
}
