import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Status badge for submissions
class SubmissionStatusBadge extends ConsumerWidget {
  final SubmissionStatus status;

  const SubmissionStatusBadge({super.key, required this.status});

  Color _getColorForStatus(SubmissionStatus status, ColorScheme colorScheme) {
    switch (status) {
      case SubmissionStatus.submitted:
        return colorScheme.primary;
      case SubmissionStatus.graded:
        return Colors.green;
      case SubmissionStatus.inProgress:
        return colorScheme.secondary;
    }
  }

  IconData _getIconForStatus(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.submitted:
        return LucideIcons.send;
      case SubmissionStatus.graded:
        return LucideIcons.circleCheck;
      case SubmissionStatus.inProgress:
        return LucideIcons.clock;
    }
  }

  String _getLabelForStatus(SubmissionStatus status, Translations t) {
    switch (status) {
      case SubmissionStatus.submitted:
        return t.submissions.status.submitted;
      case SubmissionStatus.graded:
        return t.submissions.status.graded;
      case SubmissionStatus.inProgress:
        return t.submissions.status.inProgress;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _getColorForStatus(status, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconForStatus(status), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            _getLabelForStatus(status, t),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
