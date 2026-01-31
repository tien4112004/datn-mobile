import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

part 'font_size.dart';
part 'padding_value.dart';

///This class defines light theme and dark theme
///Here we used flex color scheme with custom primary color
class Themes {
  static const double boxRadiusValue = 12.0;
  static const FontSize fontSize = FontSize();
  static const PaddingValue padding = PaddingValue();
  static const BorderRadius boxRadius = BorderRadius.all(
    Radius.circular(boxRadiusValue),
  );

  // App Primary Color - Material Design Blue
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryColorDark = Color(0xFF1976D2);
  static const Color primaryColorLight = Color(0xFF64B5F6);

  // Custom color scheme for the app
  static const FlexSchemeColor _lightColors = FlexSchemeColor(
    primary: primaryColor,
    primaryContainer: Color(0xFFBBDEFB),
    secondary: Color(0xFF03A9F4),
    secondaryContainer: Color(0xFFB3E5FC),
    tertiary: Color(0xFF00BCD4),
    tertiaryContainer: Color(0xFFB2EBF2),
  );

  static const FlexSchemeColor _darkColors = FlexSchemeColor(
    primary: Color(0xFF90CAF9),
    primaryContainer: Color(0xFF1565C0),
    secondary: Color(0xFF4FC3F7),
    secondaryContainer: Color(0xFF0277BD),
    tertiary: Color(0xFF4DD0E1),
    tertiaryContainer: Color(0xFF00838F),
  );

  static ThemeData get theme => FlexThemeData.light(
    colors: _lightColors,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    lightIsWhite: true,
    blendLevel: 20,
    appBarOpacity: 0.95,
    tabBarStyle: FlexTabBarStyle.forBackground,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      blendOnColors: false,
      inputDecoratorRadius: boxRadiusValue,
      cardRadius: boxRadiusValue,
    ),
    keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  );

  static ThemeData get darkTheme => FlexThemeData.dark(
    colors: _darkColors,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 15,
    appBarOpacity: 0.90,
    tabBarStyle: FlexTabBarStyle.forBackground,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 30,
      inputDecoratorRadius: boxRadiusValue,
      cardRadius: boxRadiusValue,
    ),
    keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  );
  // If you do not have a themeMode switch, uncomment this line
  // to let the device system mode control the theme mode:
  // themeMode: ThemeMode.system,
}

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
