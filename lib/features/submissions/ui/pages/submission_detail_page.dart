import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_grading.dart';
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_grading.dart';
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_grading.dart';
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_grading.dart';
import 'package:AIPrimary/features/submissions/domain/entity/answer_entity.dart';
import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';
import 'package:AIPrimary/features/submissions/states/controller_provider.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/score_display.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/submission_status_badge.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class SubmissionDetailPage extends ConsumerWidget {
  final String submissionId;

  const SubmissionDetailPage({
    super.key,
    @PathParam('submissionId') required this.submissionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userRole = ref.watch(userRolePod);
    final isTeacher = userRole == UserRole.teacher;

    final submissionAsync = ref.watch(submissionDetailProvider(submissionId));

    // Also fetch assignment for question details
    final assignmentAsync = submissionAsync.whenData((submission) {
      return ref.watch(assignmentPublicProvider(submission.assignmentId));
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: t.submissions.detail.title,
        actions: [
          if (isTeacher)
            submissionAsync.whenOrNull(
                  data: (submission) => IconButton(
                    onPressed: () {
                      context.router.push(
                        GradingRoute(submissionId: submissionId),
                      );
                    },
                    icon: const Icon(LucideIcons.penLine),
                    tooltip: t.submissions.detail.editGrades,
                  ),
                ) ??
                const SizedBox.shrink(),
        ],
      ),
      body: submissionAsync.easyWhen(
        skipLoadingOnRefresh: false,
        data: (submission) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(submissionDetailProvider(submissionId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header: Score summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        SubmissionStatusBadge(status: submission.status),
                        const SizedBox(height: 16),
                        if (submission.score != null)
                          ScoreDisplay(
                            score: submission.score!,
                            maxScore: submission.maxScore,
                          )
                        else
                          Text(
                            t.submissions.detail.status,
                            style: theme.textTheme.bodyLarge,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          '${t.submissions.detail.submittedAt}: ${DateFormatHelper.formatRelativeDate(submission.submittedAt, ref: ref)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (submission.gradedAt != null)
                          Text(
                            '${t.submissions.detail.gradedAt}: ${DateFormatHelper.formatRelativeDate(submission.gradedAt!, ref: ref)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Questions and answers
                  assignmentAsync.value != null
                      ? _buildQuestionsSection(
                          context,
                          ref,
                          submission,
                          assignmentAsync.value!.value!,
                          t,
                        )
                      : const Center(child: CircularProgressIndicator()),

                  const SizedBox(height: 24),

                  // Overall feedback
                  if (submission.overallFeedback != null &&
                      submission.overallFeedback!.isNotEmpty) ...[
                    Text(
                      t.submissions.detail.overallFeedback,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        submission.overallFeedback!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.info,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.submissions.detail.noFeedback,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsSection(
    BuildContext context,
    WidgetRef ref,
    SubmissionEntity submission,
    AssignmentEntity assignment,
    Translations t,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.assignments.detail.questions_,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...submission.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;

          // Find corresponding question from assignment
          final assignmentQuestion = assignment.questions.firstWhere(
            (q) => q.question.id == answer.questionId,
          );
          final question = assignmentQuestion.question;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildQuestionCard(
              context,
              ref,
              index + 1,
              question,
              answer,
              t,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    WidgetRef ref,
    int questionNumber,
    question,
    AnswerEntity answer,
    Translations t,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget questionWidget;

    switch (answer.type) {
      case QuestionType.multipleChoice:
        questionWidget = MultipleChoiceGrading(
          question: question,
          studentAnswer:
              (answer as MultipleChoiceAnswerEntity).selectedOptionId,
        );
        break;
      case QuestionType.fillInBlank:
        questionWidget = FillInBlankGrading(
          question: question,
          studentAnswers: (answer as FillInBlankAnswerEntity).blankAnswers,
        );
        break;
      case QuestionType.matching:
        questionWidget = MatchingGrading(
          question: question,
          studentAnswers: (answer as MatchingAnswerEntity).matchedPairs,
        );
        break;
      case QuestionType.openEnded:
        questionWidget = OpenEndedGrading(
          question: question,
          studentAnswer: (answer as OpenEndedAnswerEntity).response,
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number and grade
          Row(
            children: [
              Text(
                '${t.questions.question} $questionNumber',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (answer.grade != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: answer.grade!.isPerfect
                        ? Colors.green.withValues(alpha: 0.15)
                        : colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${answer.grade!.score.toStringAsFixed(1)}/${answer.grade!.maxScore}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: answer.grade!.isPerfect
                          ? Colors.green
                          : colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Question widget
          questionWidget,

          // Feedback
          if (answer.grade?.feedback != null &&
              answer.grade!.feedback!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.messageSquare,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      answer.grade!.feedback!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
