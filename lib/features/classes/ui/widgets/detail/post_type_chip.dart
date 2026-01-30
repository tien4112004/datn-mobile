import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Chip displaying the type of a post with Material 3 styling
class PostTypeChip extends StatelessWidget {
  final PostType type;

  const PostTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = _getConfig(type, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.iconColor),
          const SizedBox(width: 6),
          Text(
            type.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _ChipConfig _getConfig(PostType type, ColorScheme colorScheme) {
    switch (type) {
      case PostType.post:
        return _ChipConfig(
          icon: LucideIcons.messageCircle,
          backgroundColor: colorScheme.surfaceContainerHighest,
          borderColor: colorScheme.outlineVariant,
          iconColor: colorScheme.onSurfaceVariant,
          textColor: colorScheme.onSurfaceVariant,
        );
      case PostType.exercise:
        return _ChipConfig(
          icon: LucideIcons.clipboardList,
          backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderColor: colorScheme.primary.withValues(alpha: 0.3),
          iconColor: colorScheme.primary,
          textColor: colorScheme.onPrimaryContainer,
        );
    }
  }
}

/// Configuration for chip appearance
class _ChipConfig {
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  _ChipConfig({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}
