import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                label: t.submissions.preview.questionCount(
                  count: assignment.totalQuestions,
                ),
                color: colorScheme.primary,
              ),

              // Total points
              _InfoChip(
                label: t.submissions.preview.totalPoints(
                  points: assignment.totalPoints,
                ),
                color: colorScheme.secondary,
              ),

              // Time limit (if exists)
              if (assignment.timeLimitMinutes != null)
                _InfoChip(
                  label: t.submissions.preview.timeLimit(
                    minutes: assignment.timeLimitMinutes!,
                  ),
                  color: colorScheme.secondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
