import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Enhanced count header widget with gradient background and customization.
///
/// Provides a reusable header component for displaying counts with:
/// - Gradient background using theme colors
/// - Icon with frosted glass effect
/// - Animated count badge
/// - Customizable title and subtitle
/// - Optional action buttons
/// - Theme-aware styling and dark mode support
///
/// Usage:
/// ```dart
/// EnhancedCountHeader(
///   icon: LucideIcons.users,
///   title: 'Class Roster',
///   count: 25,
///   countLabel: 'Students',
///   onActionTap: () => showFilterDialog(),
/// )
/// ```
class EnhancedCountHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final String? countLabel;
  final String? subtitle;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  /// When provided, the animated count badge is replaced by an export-CSV
  /// icon button. The callback receives no arguments — callers are responsible
  /// for showing the appropriate sheet/dialog.
  final VoidCallback? onExportCsv;

  const EnhancedCountHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    this.countLabel,
    this.subtitle,
    this.onActionTap,
    this.actionIcon,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Icon and text
          Expanded(
            child: Row(
              children: [
                // Icon with frosted glass background
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ] else if (countLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$count ${count == 1 ? countLabel : "${countLabel}s"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right side: export button OR animated count badge + optional action
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onExportCsv != null)
                // Export CSV icon button replaces the count badge
                IconButton(
                  icon: Icon(
                    LucideIcons.fileDown,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  onPressed: onExportCsv,
                  tooltip: 'Export CSV',
                )
              else
                // Animated count badge (default)
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: count),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$value',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),

              // Optional action button
              if (onActionTap != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    actionIcon ?? LucideIcons.ellipsisVertical,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  onPressed: onActionTap,
                  tooltip: 'More options',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
