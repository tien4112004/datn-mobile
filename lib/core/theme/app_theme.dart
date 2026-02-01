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
  static const Color primaryColor = Color.fromARGB(255, 39, 95, 217);
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
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
    lightIsWhite: true,
    blendLevel: 0,
    appBarOpacity: 0.9,
    tabBarStyle: FlexTabBarStyle.forBackground,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 0,
      blendOnColors: false,
      useMaterial3Typography: true,
      inputDecoratorRadius: boxRadiusValue,
      cardRadius: boxRadiusValue,
      filledButtonRadius: boxRadiusValue,
      elevatedButtonRadius: boxRadiusValue,
      outlinedButtonRadius: boxRadiusValue,
      textButtonRadius: boxRadiusValue,
    ),
    // Disable tonal palette generation - use exact colors specified
    keyColors: const FlexKeyColors(
      useSecondary: false,
      useTertiary: false,
      useKeyColors: true,
      keepPrimary: true,
      keepPrimaryContainer: true,
    ),
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
    surfaceMode: FlexSurfaceMode.level,
    blendLevel: 0,
    appBarOpacity: 1.0,
    tabBarStyle: FlexTabBarStyle.forBackground,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 0,
      useMaterial3Typography: true,
      inputDecoratorRadius: boxRadiusValue,
      cardRadius: boxRadiusValue,
      filledButtonRadius: boxRadiusValue,
      elevatedButtonRadius: boxRadiusValue,
      outlinedButtonRadius: boxRadiusValue,
      textButtonRadius: boxRadiusValue,
    ),
    // Disable tonal palette generation - use exact colors specified
    keyColors: const FlexKeyColors(useSecondary: false, useTertiary: false),
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

/// Extension providing theme-aware utilities using the actual colorScheme.
/// Uses Material 3 color tokens for consistent theming.
extension ThemeContextExtension on BuildContext {
  /// Access to the current color scheme
  ColorScheme get _colorScheme => Theme.of(this).colorScheme;

  /// Check if the current theme brightness is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get theme-aware surface color for containers
  Color get surfaceColor => _colorScheme.surface;

  /// Get theme-aware elevated surface color
  Color get elevatedSurfaceColor => _colorScheme.surfaceContainerHigh;

  /// Get theme-aware border color - uses outline variant for subtle borders
  Color get borderColor => _colorScheme.outlineVariant;

  /// Get theme-aware divider color
  Color get dividerColor => _colorScheme.outlineVariant;

  /// Get theme-aware card background color
  Color get cardColor => _colorScheme.surfaceContainerLow;

  /// Get theme-aware secondary surface color (e.g., for chips, input fields)
  /// Uses a very subtle tint of primary for more visual interest
  Color get secondarySurfaceColor => isDarkMode
      ? _colorScheme.surfaceContainerHighest
      : _colorScheme.primary.withValues(alpha: 0.05);

  /// Get theme-aware tertiary surface color (for slight variations)
  Color get tertiarySurfaceColor => _colorScheme.surfaceContainerLowest;

  /// Get theme-aware text color for secondary text
  Color get secondaryTextColor => _colorScheme.onSurfaceVariant;

  /// Get theme-aware text color for tertiary/hint text
  Color get tertiaryTextColor => _colorScheme.outline;

  /// Get theme-aware text color for body text
  Color get bodyTextColor => _colorScheme.onSurface;

  /// Get theme-aware overlay color (for modals, dialogs)
  Color get overlayColor => _colorScheme.surface;

  /// Get the primary color directly
  Color get primaryColor => _colorScheme.primary;

  /// Get a subtle primary background (useful for selected states)
  Color get primarySurfaceColor => _colorScheme.primaryContainer;
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
