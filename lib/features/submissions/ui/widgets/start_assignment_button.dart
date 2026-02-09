import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/submissions/states/controller_provider.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Button that validates and starts assignment
class StartAssignmentButton extends ConsumerWidget {
  final String assignmentId;
  final String studentId;
  final String postId;
  final AssignmentEntity assignment;

  const StartAssignmentButton({
    super.key,
    required this.assignmentId,
    required this.studentId,
    required this.postId,
    required this.assignment,
  });

  Future<void> _handleStartAssignment(
    BuildContext context,
    WidgetRef ref,
    Translations t,
  ) async {
    // Validate if student can submit
    final validationController = ref.read(
      validationProvider(
        ValidationParams(
          assignmentId: assignmentId,
          studentId: studentId,
          answers: [],
        ),
      ).notifier,
    );

    try {
      final validation = await validationController.validate();

      if (!context.mounted) return;

      if (validation == null || !validation.canSubmit) {
        // Show error dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              t.submissions.errors.validationFailed(
                reason: validation?.reason ?? t.submissions.errors.loadFailed,
              ),
            ),
            content: validation?.attemptsRemaining != null
                ? Text(
                    t.submissions.errors.attemptsExceeded(
                      count: validation!.attemptsRemaining!,
                    ),
                  )
                : null,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.classes.ok),
              ),
            ],
          ),
        );
        return;
      }

      // Navigate to doing page
      if (context.mounted) {
        context.router.push(
          AssignmentDoingRoute(assignmentId: assignmentId, postId: postId),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.submissions.errors.validationFailed(reason: e.toString()),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _handleStartAssignment(context, ref, t),
        icon: const Icon(LucideIcons.play),
        label: Text(t.submissions.preview.startButton),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
