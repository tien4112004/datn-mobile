import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/classes/domain/entity/linked_resource_preview.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Material 3 preview card for assignment resources
/// Displays assignment metadata with subject-specific color coding
class AssignmentPreviewCard extends StatelessWidget {
  final LinkedResourcePreview preview;
  final VoidCallback onTap;

  const AssignmentPreviewCard({
    super.key,
    required this.preview,
    required this.onTap,
  });

  /// Parse subject from string to enum
  Subject _parseSubject(String? subject) {
    if (subject == null) return Subject.english;
    return Subject.values.firstWhere(
      (e) => e.displayName.toLowerCase() == subject.toLowerCase(),
      orElse: () => Subject.english,
    );
  }

  /// Get subject color for visual distinction
  Color _getSubjectColor(Subject subject) {
    switch (subject) {
      case Subject.english:
        return Themes.primaryColor; // Primary - Communication
      case Subject.mathematics:
        return const Color(0xFFDC2626); // Red - Logic
      case Subject.literature:
        return const Color(0xFF16A34A); // Green - Creativity
    }
  }

  /// Get subject icon
  IconData _getSubjectIcon(Subject subject) {
    switch (subject) {
      case Subject.english:
        return LucideIcons.messageSquare;
      case Subject.mathematics:
        return LucideIcons.calculator;
      case Subject.literature:
        return LucideIcons.bookOpen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final subject = _parseSubject(preview.subject);
    final subjectColor = _getSubjectColor(subject);
    final subjectIcon = _getSubjectIcon(subject);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 72), // Tap-friendly
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Subtle gradient background for visual interest
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              subjectColor.withValues(alpha: 0.08),
              subjectColor.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: subjectColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Subject Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: subjectColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                // Subtle shadow for depth
                boxShadow: [
                  BoxShadow(
                    color: subjectColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(subjectIcon, size: 24, color: subjectColor),
            ),

            const SizedBox(width: 12),

            // Content Column
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    preview.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Metadata Row
                  Row(
                    children: [
                      // Question Count
                      if (preview.totalQuestions != null)
                        _buildMetadataBadge(
                          context,
                          label: '${preview.totalQuestions} Q',
                          color: colorScheme.tertiary,
                        ),

                      // Total Points
                      if (preview.totalPoints != null)
                        _buildMetadataBadge(
                          context,
                          label: '${preview.totalPoints} pts',
                          color: const Color(0xFFF97316), // Orange CTA
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow Icon
            Icon(
              LucideIcons.arrowRight,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// Build metadata badge with icon and label
  Widget _buildMetadataBadge(
    BuildContext context, {
    required String label,
    required Color color,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPrimary ? 10 : 8,
        vertical: isPrimary ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isPrimary ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: isPrimary
            ? Border.all(color: color.withValues(alpha: 0.4), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // /// Get status-specific color
  // Color _getStatusColor(AssignmentStatus status, ColorScheme colorScheme) {
  //   switch (status) {
  //     case AssignmentStatus.completed:
  //       return const Color(0xFF16A34A); // Green
  //     case AssignmentStatus.draft:
  //       return colorScheme.tertiary;
  //     case AssignmentStatus.generating:
  //       return Themes.primaryColor;
  //     case AssignmentStatus.error:
  //       return colorScheme.error;
  //     case AssignmentStatus.archived:
  //       return colorScheme.outline;
  //   }
  // }
}
