import 'package:flutter/material.dart';

/// A reusable AppBar widget for the entire app
///
/// This widget provides:
/// - Customizable title with text styling
/// - Leading widget (back button, etc.)
/// - Trailing actions
/// - Consistent scrolled under elevation behavior
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title text to display in the AppBar
  final String title;

  /// Optional text style for the title
  /// If not provided, uses default styling
  final TextStyle? titleTextStyle;

  /// Optional leading widget (typically a back button)
  /// If not provided, Flutter will show default back button if applicable
  final Widget? leading;

  /// Optional list of action widgets to display on the right side
  final List<Widget>? actions;

  /// Whether to show the default back button when leading is null
  /// Defaults to true
  final bool automaticallyImplyLeading;

  /// The elevation of the AppBar
  /// Defaults to 0 for a flat appearance
  final double elevation;

  /// The elevation when content scrolls under the AppBar
  /// Defaults to 0 to maintain consistent appearance
  final double scrolledUnderElevation;

  /// Background color of the AppBar
  /// If not provided, uses the theme's default
  final Color? backgroundColor;

  /// Whether to center the title
  /// Defaults to false
  final bool centerTitle;

  const AppAppBar({
    super.key,
    required this.title,
    this.titleTextStyle,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.elevation = 0,
    this.scrolledUnderElevation = 0,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: titleTextStyle),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
