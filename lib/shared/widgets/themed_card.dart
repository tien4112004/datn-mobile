import 'package:datn_mobile/shared/utils/theme_utils.dart';
import 'package:flutter/material.dart';

/// A themed card widget that provides consistent styling across the app.
/// Eliminates the repeated container pattern:
/// ```dart
/// Container(
///   padding: EdgeInsets.all(16),
///   decoration: BoxDecoration(
///     color: isDark ? Colors.grey[850] : Colors.white,
///     borderRadius: BorderRadius.circular(16),
///     border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
///   ),
///   child: ...
/// )
/// ```
class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Widget? header;
  final IconData? headerIcon;
  final String? headerTitle;
  final Color? headerIconColor;
  final List<Widget>? headerActions;
  final Color? backgroundColor;
  final Color? borderColor;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.header,
    this.headerIcon,
    this.headerTitle,
    this.headerIconColor,
    this.headerActions,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? context.cardColor;
    final effectiveBorderColor = borderColor ?? context.borderColor;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null || headerTitle != null) ...[
            header ??
                _buildDefaultHeader(
                  context,
                  headerIcon!,
                  headerTitle!,
                  headerIconColor,
                  headerActions,
                ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildDefaultHeader(
    BuildContext context,
    IconData icon,
    String title,
    Color? iconColor,
    List<Widget>? actions,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        if (actions != null) ...actions,
      ],
    );
  }
}

/// A simpler card variant without headers, just styled container
class SimpleThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  const SimpleThemedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? context.cardColor;
    final effectiveBorderColor = borderColor ?? context.borderColor;

    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorderColor),
      ),
      child: child,
    );
  }
}
