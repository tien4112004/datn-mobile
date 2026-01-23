import 'package:flutter/material.dart';

/// Reusable skeleton card widget for loading states.
///
/// Provides a clean shimmer/skeleton UI pattern for content loading.
/// Customizable layout with support for badges, title, and subtitle placeholders.
///
/// Usage:
/// ```dart
/// SkeletonCard(
///   badgeCount: 2,
///   showSubtitle: true,
/// )
/// ```
class SkeletonCard extends StatelessWidget {
  final int badgeCount;
  final bool showSubtitle;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const SkeletonCard({
    super.key,
    this.badgeCount = 2,
    this.showSubtitle = true,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Use a more visible color for skeleton elements
    final shimmerColor = colorScheme.onSurface.withValues(alpha: 0.12);

    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges skeleton
            if (badgeCount > 0)
              Row(
                children: List.generate(
                  badgeCount,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right: index < badgeCount - 1 ? 8 : 0,
                    ),
                    child: _ShimmerBox(
                      width: index == 0 ? 100 : 80,
                      height: 24,
                      borderRadius: 6,
                      color: shimmerColor,
                    ),
                  ),
                ),
              ),
            if (badgeCount > 0) const SizedBox(height: 12),

            // Title skeleton
            _ShimmerBox(
              width: double.infinity,
              height: 20,
              borderRadius: 4,
              color: shimmerColor,
            ),

            // Subtitle skeleton
            if (showSubtitle) ...[
              const SizedBox(height: 8),
              _ShimmerBox(
                width: 200,
                height: 20,
                borderRadius: 4,
                color: shimmerColor,
              ),
            ],
          ],
        ),
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
