import 'package:flutter/material.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

/// Shared badge components for displaying question-related information
/// across the app (question bank, exams, classes, etc.)
///
/// Provides consistent styling and reduces code duplication.

/// Badge displaying question type with icon and label
class QuestionTypeBadge extends StatelessWidget {
  final QuestionType type;
  final double iconSize;
  final double fontSize;
  final EdgeInsets? padding;

  const QuestionTypeBadge({
    super.key,
    required this.type,
    this.iconSize = 14,
    this.fontSize = 11,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = QuestionType.getColor(type);
    final icon = QuestionType.getIcon(type);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            type.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge displaying difficulty level with icon and label
class DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;
  final double iconSize;
  final double fontSize;
  final EdgeInsets? padding;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.iconSize = 14,
    this.fontSize = 11,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = Difficulty.getDifficultyColor(difficulty);
    final icon = Difficulty.getDifficultyIcon(difficulty);
    final label = difficulty.displayName;

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge displaying points value
class PointsBadge extends StatelessWidget {
  final int points;
  final double iconSize;
  final double fontSize;
  final EdgeInsets? padding;

  const PointsBadge({
    super.key,
    required this.points,
    this.iconSize = 14,
    this.fontSize = 11,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: iconSize,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            '$points pts',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge displaying usage statistics
class UsageStatsBadge extends StatelessWidget {
  final int usageCount;
  final double iconSize;
  final double fontSize;
  final Color? textColor;
  final EdgeInsets? padding;

  const UsageStatsBadge({
    super.key,
    required this.usageCount,
    this.iconSize = 14,
    this.fontSize = 12,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveTextColor = textColor ?? colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.history_rounded, size: iconSize, color: effectiveTextColor),
        const SizedBox(width: 4),
        Text(
          'Used $usageCount time${usageCount != 1 ? 's' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.w500,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
