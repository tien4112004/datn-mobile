import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_grading.dart';
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_grading.dart';
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_grading.dart';
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_grading.dart';
import 'package:AIPrimary/features/submissions/domain/entity/answer_entity.dart';
import 'package:AIPrimary/features/submissions/states/controller_provider.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class GradingPage extends ConsumerStatefulWidget {
  final String submissionId;

  const GradingPage({
    super.key,
    @PathParam('submissionId') required this.submissionId,
  });

  @override
  ConsumerState<GradingPage> createState() => _GradingPageState();
}

class _GradingPageState extends ConsumerState<GradingPage> {
  final Map<String, double> _questionScores = {};
  final Map<String, String> _questionFeedback = {};
  final TextEditingController _overallFeedbackController =
      TextEditingController();

  @override
  void dispose() {
    _overallFeedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final t = ref.read(translationsPod);

    try {
      final gradeController = ref.read(
        gradeSubmissionControllerProvider.notifier,
      );

      await gradeController.gradeSubmission(
        submissionId: widget.submissionId,
        questionScores: _questionScores,
        questionFeedback: _questionFeedback.isNotEmpty
            ? _questionFeedback
            : null,
        overallFeedback: _overallFeedbackController.text.trim().isNotEmpty
            ? _overallFeedbackController.text.trim()
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.submissions.grading.saveSuccess),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      context.router.maybePop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.submissions.grading.saveError(error: e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final submissionAsync = ref.watch(
      submissionDetailProvider(widget.submissionId),
    );

    final assignmentAsync = submissionAsync.whenData((submission) {
      return ref.watch(assignmentPublicProvider(submission.assignmentId));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(t.submissions.grading.title),
        actions: [
          IconButton(
            onPressed: _handleSave,
            icon: const Icon(LucideIcons.save),
            tooltip: t.submissions.grading.saveButton,
          ),
        ],
      ),
      body: submissionAsync.easyWhen(
        skipLoadingOnRefresh: false,
        data: (submission) {
          // Initialize scores from existing grades
          if (_questionScores.isEmpty) {
            for (final answer in submission.questions) {
              if (answer.grade != null) {
                _questionScores[answer.questionId] = answer.grade!.score;
                if (answer.grade!.feedback != null) {
                  _questionFeedback[answer.questionId] =
                      answer.grade!.feedback!;
                }
              }
            }
            if (submission.overallFeedback != null) {
              _overallFeedbackController.text = submission.overallFeedback!;
            }
          }

          return assignmentAsync.value != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Student info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.submissions.grading.studentInfo,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              submission.student.firstName,
                              style: theme.textTheme.bodyLarge,
                            ),
                            Text(
                              submission.student.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${t.submissions.detail.submittedAt}: ${DateFormatHelper.formatRelativeDate(submission.submittedAt, ref: ref)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Questions for grading
                      ...submission.questions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final answer = entry.value;

                        final assignmentQuestion = assignmentAsync
                            .value!
                            .value!
                            .questions
                            .firstWhere(
                              (q) => q.question.id == answer.questionId,
                            );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildGradingQuestionCard(
                            context,
                            ref,
                            index + 1,
                            assignmentQuestion.question,
                            assignmentQuestion.points,
                            answer,
                            t,
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Overall feedback
                      Text(
                        t.submissions.grading.overallFeedback,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _overallFeedbackController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Enter overall feedback...',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _handleSave,
                          icon: const Icon(LucideIcons.save),
                          label: Text(t.submissions.grading.saveButton),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator());
        },
        loadingWidget: () => const Center(child: CircularProgressIndicator()),
        errorWidget: (error, stack) =>
            Center(child: Text(t.submissions.errors.loadFailed)),
      ),
    );
  }

  Widget _buildGradingQuestionCard(
    BuildContext context,
    WidgetRef ref,
    int questionNumber,
    question,
    double maxScore,
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

    final scoreController = TextEditingController(
      text:
          _questionScores[answer.questionId]?.toString() ??
          answer.grade?.score.toString() ??
          '',
    );

    final feedbackController = TextEditingController(
      text:
          _questionFeedback[answer.questionId] ?? answer.grade?.feedback ?? '',
    );

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
          // Question number
          Row(
            children: [
              Text(
                '${t.questions.question} $questionNumber',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (answer.grade?.isAutoGraded == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t.submissions.grading.autoGraded,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Question widget
          questionWidget,

          const SizedBox(height: 16),

          // Score input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: scoreController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        '${t.submissions.grading.score} (Max: $maxScore)',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    final score = double.tryParse(value);
                    if (score != null) {
                      _questionScores[answer.questionId] = score;
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Feedback input
          TextField(
            controller: feedbackController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: t.submissions.grading.feedback,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              isDense: true,
            ),
            onChanged: (value) {
              _questionFeedback[answer.questionId] = value;
            },
          ),
        ],
      ),
    );
  }
}
