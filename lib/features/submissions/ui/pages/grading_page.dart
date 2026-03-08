import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/context/context_display_card.dart';
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
import 'package:AIPrimary/shared/helper/global_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A question + its matching submission answer, with display number
class _GradingItem {
  final AssignmentQuestionEntity assignmentQuestion;
  final AnswerEntity answer;
  final int displayNumber;

  const _GradingItem({
    required this.assignmentQuestion,
    required this.answer,
    required this.displayNumber,
  });
}

/// Group of questions sharing the same context (or a standalone question)
class _GradingGroup {
  final String? contextId;
  final ContextEntity? context;
  final List<_GradingItem> items;

  const _GradingGroup({this.contextId, this.context, required this.items});

  bool get isContextGroup => contextId != null;
  int get startingDisplayNumber => items.first.displayNumber;
}

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

class _GradingPageState extends ConsumerState<GradingPage>
    with GlobalHelper<GradingPage> {
  final Map<String, double> _questionScores = {};
  final Map<String, String> _questionFeedback = {};
  final TextEditingController _overallFeedbackController =
      TextEditingController();

  int _currentGroupIndex = 0;
  List<_GradingGroup> _groups = [];
  String _lastGroupsFingerprint = '';
  bool _initialized = false;

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

      showSuccessSnack(child: Text(t.submissions.grading.saveSuccess));
      context.router.maybePop();
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(
        child: Text(t.submissions.grading.saveError(error: e.toString())),
      );
    }
  }

  String _getGroupTitle(_GradingGroup group, Translations t) {
    if (group.items.length == 1) {
      return t.submissions.doing.questionNumber(
        number: group.startingDisplayNumber,
      );
    } else {
      final start = group.startingDisplayNumber;
      final end = start + group.items.length - 1;
      return t.submissions.doing.questionRange(start: start, end: end);
    }
  }

  List<_GradingGroup> _buildGroups(
    List<AssignmentQuestionEntity> assignmentQuestions,
    List<AnswerEntity> submissionAnswers,
    List<ContextEntity> contexts,
  ) {
    final answerMap = {for (final a in submissionAnswers) a.questionId: a};
    final contextMap = {for (final c in contexts) c.id: c};

    final groups = <_GradingGroup>[];
    final processedIds = <String>{};
    int displayNumber = 1;

    for (int i = 0; i < assignmentQuestions.length; i++) {
      final aq = assignmentQuestions[i];
      final qId = aq.question.id;

      if (processedIds.contains(qId)) continue;

      final answer = answerMap[qId];
      if (answer == null) continue;

      final contextId = aq.contextId;

      if (contextId != null && contextId.isNotEmpty) {
        final items = <_GradingItem>[];

        for (int j = i; j < assignmentQuestions.length; j++) {
          final aq2 = assignmentQuestions[j];
          if (aq2.contextId != contextId) continue;
          final qId2 = aq2.question.id;
          if (processedIds.contains(qId2)) continue;
          final a2 = answerMap[qId2];
          if (a2 == null) continue;

          items.add(
            _GradingItem(
              assignmentQuestion: aq2,
              answer: a2,
              displayNumber: displayNumber++,
            ),
          );
          processedIds.add(qId2);
        }

        groups.add(
          _GradingGroup(
            contextId: contextId,
            context: contextMap[contextId],
            items: items,
          ),
        );
      } else {
        groups.add(
          _GradingGroup(
            contextId: null,
            context: null,
            items: [
              _GradingItem(
                assignmentQuestion: aq,
                answer: answer,
                displayNumber: displayNumber++,
              ),
            ],
          ),
        );
        processedIds.add(qId);
      }
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final submissionAsync = ref.watch(
      submissionDetailProvider(widget.submissionId),
    );

    return submissionAsync.easyWhen(
      skipLoadingOnRefresh: false,
      data: (submission) {
        // Initialize scores/feedback once from existing grades
        if (!_initialized) {
          _initialized = true;
          for (final answer in submission.questions) {
            if (answer.grade != null) {
              _questionScores[answer.questionId] = answer.grade!.score;
              if (answer.grade!.feedback != null) {
                _questionFeedback[answer.questionId] = answer.grade!.feedback!;
              }
            }
          }
          if (submission.overallFeedback != null) {
            _overallFeedbackController.text = submission.overallFeedback!;
          }
        }

        final assignmentAsync = ref.watch(
          assignmentByPostIdProvider(submission.postId),
        );

        return assignmentAsync.when(
          data: (assignment) {
            // Rebuild groups only when question list changes
            final fingerprint = assignment.questions
                .map((q) => q.question.id)
                .join(',');
            if (_groups.isEmpty || fingerprint != _lastGroupsFingerprint) {
              _groups = _buildGroups(
                assignment.questions,
                submission.questions,
                assignment.contexts,
              );
              _lastGroupsFingerprint = fingerprint;
              if (_currentGroupIndex >= _groups.length) {
                _currentGroupIndex = 0;
              }
            }

            if (_groups.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: Text(t.submissions.grading.title)),
                body: Center(child: Text(t.submissions.doing.noQuestions)),
              );
            }

            final currentGroup = _groups[_currentGroupIndex];

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGroupTitle(currentGroup, t),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: _handleSave,
                    icon: const Icon(LucideIcons.save),
                    tooltip: t.submissions.grading.saveButton,
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Progress bar
                  LinearProgressIndicator(
                    value: (_currentGroupIndex + 1) / _groups.length,
                    minHeight: 4,
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Student info on first group only
                          if (_currentGroupIndex == 0) ...[
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
                          ],

                          // Context card for context groups
                          if (currentGroup.isContextGroup &&
                              currentGroup.context != null) ...[
                            ContextDisplayCard(
                              context: currentGroup.context!,
                              initiallyExpanded: true,
                              isEditMode: false,
                              readingPassageLabel:
                                  t.assignments.context.readingPassage,
                            ),
                            const SizedBox(height: 24),
                            Divider(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                              thickness: 1,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t.submissions.doing.questionCount(
                                    count: currentGroup.items.length,
                                  ),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Grading cards for each question in the group
                          ...currentGroup.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildGradingQuestionCard(
                                item.displayNumber,
                                item.assignmentQuestion.question,
                                item.assignmentQuestion.points,
                                item.answer,
                                t,
                                theme,
                                colorScheme,
                              ),
                            ),
                          ),

                          // Overall feedback + save button on last group
                          if (_currentGroupIndex == _groups.length - 1) ...[
                            const SizedBox(height: 8),
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
                                hintText:
                                    t.submissions.grading.overallFeedbackHint,
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _handleSave,
                                icon: const Icon(LucideIcons.save),
                                label: Text(t.submissions.grading.saveButton),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_currentGroupIndex > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _currentGroupIndex--),
                              icon: const Icon(LucideIcons.chevronLeft),
                              label: Text(t.classes.previous),
                            ),
                          ),
                        if (_currentGroupIndex > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _currentGroupIndex < _groups.length - 1
                              ? FilledButton.icon(
                                  onPressed: () =>
                                      setState(() => _currentGroupIndex++),
                                  icon: const Icon(LucideIcons.chevronRight),
                                  label: Text(t.classes.next),
                                )
                              : FilledButton.icon(
                                  onPressed: _handleSave,
                                  icon: const Icon(LucideIcons.save),
                                  label: Text(t.submissions.grading.saveButton),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Scaffold(
            appBar: AppBar(title: Text(t.submissions.grading.title)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: Text(t.submissions.grading.title)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.submissions.errors.loadFailed),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loadingWidget: () => Scaffold(
        appBar: AppBar(title: Text(t.submissions.grading.title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(t.submissions.grading.title)),
        body: Center(child: Text(t.submissions.errors.loadFailed)),
      ),
    );
  }

  Widget _buildGradingQuestionCard(
    int questionNumber,
    question,
    double maxScore,
    AnswerEntity answer,
    Translations t,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
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
          questionWidget,
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: scoreController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: t.submissions.grading.scoreWithMax(
                      max: maxScore,
                    ),
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
