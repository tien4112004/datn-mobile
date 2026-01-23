import 'package:flutter/material.dart';

/// Reusable skeleton list tile widget for loading states.
///
/// Provides a minimal skeleton UI pattern for list items.
/// Supports leading icon, title, subtitle, and trailing elements.
///
/// Usage:
/// ```dart
/// SkeletonListTile(
///   showLeading: true,
///   showSubtitle: true,
///   showTrailing: true,
/// )
/// ```
class SkeletonListTile extends StatelessWidget {
  final bool showLeading;
  final bool showSubtitle;
  final bool showTrailing;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const SkeletonListTile({
    super.key,
    this.showLeading = false,
    this.showSubtitle = false,
    this.showTrailing = false,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final skeletonColor = colorScheme.surfaceContainerHighest;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Leading element (e.g., avatar/icon)
          if (showLeading) ...[
            _ShimmerBox(
              width: 40,
              height: 40,
              borderRadius: 20, // Circular
              color: skeletonColor,
            ),
            const SizedBox(width: 12),
          ],

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                _ShimmerBox(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                  color: skeletonColor,
                ),

                // Subtitle
                if (showSubtitle) ...[
                  const SizedBox(height: 8),
                  _ShimmerBox(
                    width: 150,
                    height: 14,
                    borderRadius: 4,
                    color: skeletonColor,
                  ),
                ],
              ],
            ),
          ),

          // Trailing element (e.g., icon/button)
          if (showTrailing) ...[
            const SizedBox(width: 12),
            _ShimmerBox(
              width: 24,
              height: 24,
              borderRadius: 4,
              color: skeletonColor,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer box component for skeleton loading states
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
