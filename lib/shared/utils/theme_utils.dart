import 'package:flutter/material.dart';

/// Extension providing theme-aware utilities to reduce duplication
/// of dark mode checks and color resolution across the app.
///
/// Used to eliminate the repeated pattern:
/// ```dart
/// final isDark = Theme.of(context).brightness == Brightness.dark;
/// color: isDark ? Colors.grey[900] : Colors.white;
/// ```
extension ThemeContextExtension on BuildContext {
  /// Check if the current theme brightness is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get theme-aware surface color for containers
  /// Dark: grey[900], Light: white
  Color get surfaceColor => isDarkMode ? Colors.grey[900]! : Colors.white;

  /// Get theme-aware elevated surface color
  /// Dark: grey[850], Light: white
  Color get elevatedSurfaceColor =>
      isDarkMode ? Colors.grey[850]! : Colors.white;

  /// Get theme-aware border color
  /// Dark: grey[800], Light: grey[200]
  Color get borderColor => isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

  /// Get theme-aware divider color
  /// Dark: grey[700], Light: grey[300]
  Color get dividerColor => isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

  /// Get theme-aware card background color
  /// Dark: grey[850], Light: white
  Color get cardColor => isDarkMode ? Colors.grey[850]! : Colors.white;

  /// Get theme-aware secondary surface color (e.g., for chips, input fields)
  /// Dark: grey[800], Light: grey[100]
  Color get secondarySurfaceColor =>
      isDarkMode ? Colors.grey[800]! : Colors.grey[100]!;

  /// Get theme-aware tertiary surface color (for slight variations)
  /// Dark: grey[800], Light: grey[50]
  Color get tertiarySurfaceColor =>
      isDarkMode ? Colors.grey[800]! : Colors.grey[50]!;

  /// Get theme-aware text color for secondary text
  /// Dark: grey[400], Light: grey[600]
  Color get secondaryTextColor =>
      isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

  /// Get theme-aware text color for tertiary/hint text
  /// Dark: grey[500], Light: grey[500]
  Color get tertiaryTextColor => Colors.grey[500]!;

  /// Get theme-aware text color for body text
  /// Dark: grey[300], Light: grey[700]
  Color get bodyTextColor => isDarkMode ? Colors.grey[300]! : Colors.grey[700]!;

  /// Get theme-aware overlay color (for modals, dialogs)
  /// Dark: grey[900], Light: white
  Color get overlayColor => isDarkMode ? Colors.grey[900]! : Colors.white;
}

/// Provides common BoxDecoration patterns used throughout the app
class ThemeDecorations {
  ThemeDecorations._();

  /// Standard container decoration with bottom border (used for app bars)
  static BoxDecoration containerWithBottomBorder(BuildContext context) {
    return BoxDecoration(
      color: context.surfaceColor,
      border: Border(bottom: BorderSide(color: context.borderColor)),
    );
  }

  /// Standard container decoration with top border (used for bottom bars)
  static BoxDecoration containerWithTopBorder(BuildContext context) {
    return BoxDecoration(
      color: context.surfaceColor,
      border: Border(top: BorderSide(color: context.borderColor)),
    );
  }

  /// Card decoration with border and rounded corners
  static BoxDecoration cardDecoration(
    BuildContext context, {
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: context.borderColor),
    );
  }

  /// Input field decoration (filled background, no border)
  static BoxDecoration inputDecoration(
    BuildContext context, {
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: context.secondarySurfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Chip decoration (subtle background)
  static BoxDecoration chipDecoration(
    BuildContext context, {
    double borderRadius = 20,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: context.secondarySurfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? context.borderColor),
    );
  }

  /// Bottom sheet decoration with top rounded corners
  static BoxDecoration bottomSheetDecoration(
    BuildContext context, {
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: context.overlayColor,
      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
    );
  }
}
