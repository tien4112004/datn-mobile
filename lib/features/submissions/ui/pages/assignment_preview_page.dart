import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';
import 'package:AIPrimary/features/submissions/states/controller_provider.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/assignment_preview_header.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/previous_submissions_list.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/question_breakdown_card.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/start_assignment_button.dart';
import 'package:AIPrimary/features/submissions/utils/validation_message_mapper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class AssignmentPreviewPage extends ConsumerWidget {
  final String assignmentId;
  final String? postId;

  const AssignmentPreviewPage({
    super.key,
    @PathParam('assignmentId') required this.assignmentId,
    @QueryParam('postId') this.postId,
  });

  Future<void> _handleStartNewAttempt(
    BuildContext context,
    WidgetRef ref,
    dynamic t,
    String assignmentId,
    String studentId,
    String postId,
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
        // Translate error and warning messages
        final translatedErrors = validation?.errors != null
            ? ValidationMessageMapper.mapErrors(validation!.errors, t)
            : [t.submissions.errors.loadFailed];

        // Show error dialog with translated messages
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(
              LucideIcons.circleAlert,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            title: Text(t.submissions.errors.validationErrors),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display errors
                  if (translatedErrors.isNotEmpty) ...[
                    ...translatedErrors.map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              LucideIcons.circleX,
                              size: 16,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(error)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
    final colorScheme = theme.colorScheme;

    // Fetch assignment using public endpoint
    final assignmentAsync = ref.watch(assignmentPostProvider(postId!));

    // Fetch student's previous submissions
    final userId = ref.watch(userControllerPod).value?.id;
    final submissionsAsync = userId != null
        ? ref.watch(
            studentSubmissionsProvider(
              StudentSubmissionsParams(
                assignmentId: assignmentId,
                studentId: userId,
              ),
            ),
          )
        : const AsyncValue<List<SubmissionEntity>>.data([]);

    // Refresh submissions when page is mounted/resumed
    ref.listen<AsyncValue<List<SubmissionEntity>>>(
      studentSubmissionsProvider(
        StudentSubmissionsParams(
          assignmentId: assignmentId,
          studentId: userId ?? '',
        ),
      ),
      (previous, next) {
        // Submissions updated, page will rebuild automatically
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.submissions.preview.title),
        centerTitle: false,
      ),
      body: assignmentAsync.easyWhen(
        skipLoadingOnRefresh: false,
        data: (assignment) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                studentSubmissionsProvider(
                  StudentSubmissionsParams(
                    assignmentId: assignmentId,
                    studentId: userId!,
                  ),
                ),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Assignment metadata header
                  AssignmentPreviewHeader(assignment: assignment),

                  const SizedBox(height: 24),

                  // Question breakdown
                  QuestionBreakdownCard(assignment: assignment),

                  const SizedBox(height: 24),

                  // Previous submissions (if any)
                  submissionsAsync.easyWhen(
                    skipLoadingOnRefresh: false,
                    data: (submissions) {
                      if (submissions.isEmpty) {
                        // Empty state - no previous attempts
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.submissions.preview.previousAttempts,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.clipboardList,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.submissions.preview.noAttempts,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t
                                              .submissions
                                              .preview
                                              .noAttemptsDescription,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.submissions.preview.previousAttempts,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PreviousSubmissionsList(submissions: submissions),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                    loadingWidget: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.submissions.preview.previousAttempts,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Loading shimmer effect
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                t.submissions.preview.loadingAttempts,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                    errorWidget: (error, stack) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.submissions.preview.previousAttempts,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.circleAlert,
                                color: colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  t.submissions.preview.loadAttemptsError,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Action buttons
                  submissionsAsync.maybeWhen(
                    data: (submissions) {
                      // Show view result button if student has submitted
                      if (submissions.isNotEmpty) {
                        return Column(
                          children: [
                            // Start new attempt button (outlined)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await _handleStartNewAttempt(
                                    context,
                                    ref,
                                    t,
                                    assignmentId,
                                    userId!,
                                    postId!,
                                  );
                                },
                                icon: const Icon(LucideIcons.play),
                                label: Text(t.submissions.preview.startNew),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Show start button if no submissions
                      return StartAssignmentButton(
                        assignmentId: assignmentId,
                        studentId: userId!,
                        postId: postId!,
                        assignment: assignment,
                      );
                    },
                    orElse: () => StartAssignmentButton(
                      assignmentId: assignmentId,
                      studentId: userId!,
                      postId: postId!,
                      assignment: assignment,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loadingWidget: () => const Center(child: CircularProgressIndicator()),
        errorWidget: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.circleAlert, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                t.submissions.errors.loadFailed,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.invalidate(assignmentByPostIdProvider(postId!));
                },
                child: Text(t.classes.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
