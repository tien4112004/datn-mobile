import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';
import 'package:AIPrimary/features/submissions/states/controller_provider.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/assignment_preview_header.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/previous_submissions_list.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/question_breakdown_card.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/start_assignment_button.dart';
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
                        return const SizedBox.shrink();
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
                    loadingWidget: () => const SizedBox.shrink(),
                    errorWidget: (error, stack) => const SizedBox.shrink(),
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
                  ref.invalidate(assignmentPublicProvider(assignmentId));
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
