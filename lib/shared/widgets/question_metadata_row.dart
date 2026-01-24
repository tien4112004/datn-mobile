import 'package:flutter/material.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/shared/widgets/question_badges.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Reusable metadata row component for displaying question information
///
/// Shows usage statistics, difficulty, creation date, and other metadata
/// in a consistent format across question lists, detail views, and exams.
class QuestionMetadataRow extends StatelessWidget {
  final Difficulty difficulty;
  final int? usageCount;
  final DateTime? createdAt;
  final bool showDate;
  final bool showUsage;
  final MainAxisAlignment alignment;
  final double spacing;

  const QuestionMetadataRow({
    super.key,
    required this.difficulty,
    this.usageCount,
    this.createdAt,
    this.showDate = true,
    this.showUsage = true,
    this.alignment = MainAxisAlignment.start,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: alignment,
      children: [
        // Usage stats
        if (showUsage && usageCount != null) ...[
          UsageStatsBadge(
            usageCount: usageCount!,
            iconSize: 14,
            fontSize: 12,
            textColor: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: spacing),
        ],

        // Difficulty badge
        DifficultyBadge(difficulty: difficulty, iconSize: 14, fontSize: 11),

        // Creation date
        if (showDate && createdAt != null) ...[
          SizedBox(width: spacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(createdAt!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Compact version for footer displays
class CompactMetadataRow extends StatelessWidget {
  final Difficulty difficulty;
  final Subject? subject;

  const CompactMetadataRow({super.key, required this.difficulty, this.subject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final badgeColor = Difficulty.getDifficultyColor(difficulty);
    final icon = Difficulty.getDifficultyIcon(difficulty);

    return Row(
      children: [
        // Usage count
        if (subject != null) ...[
          Icon(
            LucideIcons.bookOpen,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          Text(
            ' ${subject?.displayName} ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Difficulty indicator (icon + text only, no badge)
        Icon(icon, size: 14, color: badgeColor),
        const SizedBox(width: 4),
        Text(
          difficulty.displayName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: badgeColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
