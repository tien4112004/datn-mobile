import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Widget displaying assignment metadata in preview page
class AssignmentPreviewHeader extends ConsumerWidget {
  final AssignmentEntity assignment;

  const AssignmentPreviewHeader({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            assignment.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          // Description (if exists)
          if (assignment.description != null &&
              assignment.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              assignment.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Metadata row
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              // Total questions
              _InfoChip(
                icon: LucideIcons.fileText,
                label: t.submissions.preview.questionCount(
                  count: assignment.totalQuestions,
                ),
                color: colorScheme.primary,
              ),

              // Total points
              _InfoChip(
                icon: LucideIcons.target,
                label: t.submissions.preview.totalPoints(
                  points: assignment.totalPoints,
                ),
                color: colorScheme.secondary,
              ),

              // Time limit (if exists)
              if (assignment.timeLimitMinutes != null)
                _InfoChip(
                  icon: LucideIcons.clock,
                  label: t.submissions.preview.timeLimit(
                    minutes: assignment.timeLimitMinutes!,
                  ),
                  color: colorScheme.tertiary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
