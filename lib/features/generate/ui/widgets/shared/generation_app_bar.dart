import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A reusable app bar for presentation generation pages.
/// Eliminates the duplicate `_buildAppBar` implementations across
/// presentation_generate_page, presentation_customization_page, and outline_editor_page.
///
/// Standard pattern being replaced:
/// ```dart
/// Container(
///   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///   decoration: BoxDecoration(
///     color: isDark ? Colors.grey[900] : Colors.white,
///     border: Border(bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
///   ),
///   child: Row(...)
/// )
/// ```
class GenerationAppBar extends StatelessWidget {
  /// The title to display. Can be a String or a custom Widget
  final dynamic title;

  /// Leading widget (defaults to back button if onBack is provided)
  final Widget? leading;

  /// Callback when back button is pressed
  final VoidCallback? onBack;

  /// Trailing action widgets (e.g., settings button, help button)
  final List<Widget>? actions;

  /// Custom padding (defaults to symmetric(horizontal: 16, vertical: 12))
  final EdgeInsetsGeometry? padding;

  const GenerationAppBar({
    super.key,
    required this.title,
    this.leading,
    this.onBack,
    this.actions,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ThemeDecorations.containerWithBottomBorder(context),
      child: Row(
        children: [
          // Leading widget or back button
          if (leading != null)
            leading!
          else if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (leading != null || onBack != null) const SizedBox(width: 12),

          // Title
          Expanded(child: _buildTitle(context)),

          // Trailing actions
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (title is String) {
      return Text(
        title as String,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
      );
    } else if (title is Widget) {
      return title as Widget;
    } else {
      throw ArgumentError('title must be either String or Widget');
    }
  }
}
