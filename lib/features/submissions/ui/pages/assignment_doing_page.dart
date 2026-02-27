import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/context/context_display_card.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_doing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_doing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_doing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_doing.dart';
import 'package:AIPrimary/features/submissions/domain/entity/answer_entity.dart';
import 'package:AIPrimary/features/submissions/states/controller_provider.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/question_navigator.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/timer_widget.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/loading_overlay_pod.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Represents a group of questions, either sharing a context or standalone
class QuestionGroup {
  final String? contextId;
  final ContextEntity? context;
  final List<AssignmentQuestionEntity> questions;
  final List<int> questionIndices; // Original indices in flat list

  QuestionGroup({
    this.contextId,
    this.context,
    required this.questions,
    required this.questionIndices,
  });

  bool get isContextGroup => contextId != null;
  int get startingDisplayNumber => questionIndices.first + 1;
}

@RoutePage()
class AssignmentDoingPage extends ConsumerStatefulWidget {
  final String assignmentId;
  final String? postId;

  const AssignmentDoingPage({
    super.key,
    @PathParam('assignmentId') required this.assignmentId,
    @QueryParam('postId') this.postId,
  });

  @override
  ConsumerState<AssignmentDoingPage> createState() =>
      _AssignmentDoingPageState();
}

class _AssignmentDoingPageState extends ConsumerState<AssignmentDoingPage> {
  int _currentGroupIndex = 0;
  List<QuestionGroup> _questionGroups = [];
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  Future<void> _handleSubmit() async {
    final t = ref.read(translationsPod);
    final theme = Theme.of(context);

    if (widget.postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.submissions.errors.missingPostId),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final assignmentAsync = ref.read(
      assignmentByPostIdProvider(widget.postId!),
    );

    final assignment = assignmentAsync.value;
    if (assignment == null) return;

    final answerController = ref.read(
      answerCollectionProvider(assignment).notifier,
    );

    // Validate all questions answered
    final unanswered = answerController.validateAnswers();

    if (unanswered.isNotEmpty) {
      // Group unanswered questions by context for better clarity
      final unansweredByContext = <String?, List<int>>{};
      for (final idx in unanswered) {
        final contextId = assignment.questions[idx].contextId;
        unansweredByContext.putIfAbsent(contextId, () => []);
        unansweredByContext[contextId]!.add(idx + 1); // 1-based
      }

      // Build the content showing grouped unanswered questions
      final contentWidgets = <Widget>[];
      for (final entry in unansweredByContext.entries) {
        final contextId = entry.key;
        final questionNums = entry.value.join(", ");

        if (contextId != null) {
          ContextEntity? contextEntity;
          try {
            contextEntity = assignment.contexts.firstWhere(
              (c) => c.id == contextId,
            );
          } catch (e) {
            contextEntity = null;
          }

          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                t.submissions.doing.contextQuestions(
                  context: contextEntity?.title ?? t.submissions.doing.context,
                  questions: questionNums,
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        } else {
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                t.submissions.doing.standaloneQuestions(
                  questions: questionNums,
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }
      }

      // Show incomplete warning
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.submissions.doing.incompleteWarning),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contentWidgets,
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

    // Confirm submission
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.submissions.doing.submitButton),
        content: Text(t.submissions.doing.confirmSubmit),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.classes.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.submissions.doing.submitButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Submit answers with loading overlay
    try {
      // Show loading overlay
      ref.read(loadingOverlayPod.notifier).state = true;

      final answers = answerController.getAnswersForSubmission();
      final submissionController = ref.read(
        createSubmissionControllerProvider.notifier,
      );

      await submissionController.submitAssignment(
        postId: widget.postId!,
        studentId: ref.read(userControllerPod).value!.id,
        answers: answers,
      );

      if (!mounted) return;

      // Hide loading overlay
      ref.read(loadingOverlayPod.notifier).state = false;

      // Pop back to preview page (which will refresh and show the new submission)
      context.router.pop();
    } catch (e) {
      // Hide loading overlay on error
      ref.read(loadingOverlayPod.notifier).state = false;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.submissions.errors.submitFailed(error: e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showQuestionNavigator(BuildContext context, int totalQuestions) {
    final assignment = ref
        .read(assignmentByPostIdProvider(widget.postId!))
        .value;

    if (assignment == null) return;

    final answerState = ref.read(answerCollectionProvider(assignment));

    // Get the first question index in the current group
    final currentQuestionIndex = _questionGroups.isNotEmpty
        ? _questionGroups[_currentGroupIndex].questionIndices.first
        : 0;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: QuestionNavigator(
          currentIndex: currentQuestionIndex,
          totalQuestions: totalQuestions,
          answeredQuestions: answerState.answers.keys.where((qId) {
            final answer = answerState.answers[qId];
            return answer?.isAnswered ?? false;
          }).toList(),
          onQuestionSelected: (index) {
            // Find which group this question index belongs to
            for (int i = 0; i < _questionGroups.length; i++) {
              if (_questionGroups[i].questionIndices.contains(index)) {
                setState(() => _currentGroupIndex = i);
                break;
              }
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  /// Helper to check if groups need to be rebuilt
  String _getAssignmentFingerprint(AssignmentEntity assignment) {
    return assignment.questions.map((q) => q.question.id).join(',');
  }

  String _lastAssignmentFingerprint = '';

  /// Gets the title for the current group
  String _getGroupTitle(QuestionGroup group) {
    final t = ref.read(translationsPod);
    if (group.questions.length == 1) {
      return t.submissions.doing.questionNumber(
        number: group.startingDisplayNumber,
      );
    } else {
      final start = group.startingDisplayNumber;
      final end = start + group.questions.length - 1;
      return t.submissions.doing.questionRange(start: start, end: end);
    }
  }

  /// Builds question groups from assignment questions
  /// Groups consecutive questions with the same contextId together
  List<QuestionGroup> _buildQuestionGroups(AssignmentEntity assignment) {
    final groups = <QuestionGroup>[];
    final processedIndices = <int>{};

    for (int i = 0; i < assignment.questions.length; i++) {
      if (processedIndices.contains(i)) continue;

      final question = assignment.questions[i];
      final contextId = question.contextId;

      if (contextId != null && contextId.isNotEmpty) {
        // Find all questions with this contextId
        final questionsInGroup = <AssignmentQuestionEntity>[];
        final indicesInGroup = <int>[];

        for (int j = i; j < assignment.questions.length; j++) {
          if (assignment.questions[j].contextId == contextId) {
            questionsInGroup.add(assignment.questions[j]);
            indicesInGroup.add(j);
            processedIndices.add(j);
          }
        }

        // Find the context entity
        ContextEntity? contextEntity;
        try {
          contextEntity = assignment.contexts.firstWhere(
            (c) => c.id == contextId,
          );
        } catch (e) {
          contextEntity = null;
        }

        groups.add(
          QuestionGroup(
            contextId: contextId,
            context: contextEntity,
            questions: questionsInGroup,
            questionIndices: indicesInGroup,
          ),
        );
      } else {
        // Standalone question
        groups.add(
          QuestionGroup(
            contextId: null,
            context: null,
            questions: [question],
            questionIndices: [i],
          ),
        );
        processedIndices.add(i);
      }
    }

    return groups;
  }

  /// Builds the widget for a question group (context group or standalone)
  Widget _buildGroupWidget(
    QuestionGroup group,
    AnswerCollectionState answerState,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.read(translationsPod);

    if (group.isContextGroup && group.context != null) {
      // Context group: show context + all questions
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Context card
          ContextDisplayCard(
            context: group.context!,
            initiallyExpanded: true,
            isEditMode: false,
            readingPassageLabel: t.assignments.context.readingPassage,
          ),
          const SizedBox(height: 24),
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            thickness: 1,
          ),
          const SizedBox(height: 16),

          // Questions header
          Row(
            children: [
              Icon(Icons.quiz_outlined, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                t.submissions.doing.questionCount(
                  count: group.questions.length,
                ),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // All questions in this group
          ...group.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final assignmentQuestion = entry.value;
            final questionNumber = group.startingDisplayNumber + index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.submissions.doing.questionNumber(
                        number: questionNumber,
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuestionWidget(
                    assignmentQuestion.question,
                    answerState.answers[assignmentQuestion.question.id],
                  ),
                ],
              ),
            );
          }),
        ],
      );
    } else {
      // Standalone question
      final assignmentQuestion = group.questions.first;
      return _buildQuestionWidget(
        assignmentQuestion.question,
        answerState.answers[assignmentQuestion.question.id],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final assignmentAsync = ref.watch(
      assignmentByPostIdProvider(widget.postId!),
    );

    return SafeArea(
      child: assignmentAsync.easyWhen(
        skipLoadingOnRefresh: false,
        data: (assignment) {
          final answerState = ref.watch(answerCollectionProvider(assignment));
          final totalQuestions = assignment.questions.length;

          if (totalQuestions == 0) {
            return Scaffold(
              appBar: AppBar(title: Text(t.submissions.doing.title)),
              body: Center(child: Text(t.submissions.doing.noQuestions)),
            );
          }

          // Build question groups only when the assignment questions change
          final fingerprint = _getAssignmentFingerprint(assignment);
          if (_questionGroups.isEmpty ||
              fingerprint != _lastAssignmentFingerprint) {
            _questionGroups = _buildQuestionGroups(assignment);
            _lastAssignmentFingerprint = fingerprint;
            // Ensure current group index is valid
            if (_currentGroupIndex >= _questionGroups.length) {
              _currentGroupIndex = 0;
            }
          }

          final progress = answerState.progress;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t.classes.warning),
                  content: Text(t.submissions.doing.leaveConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(t.classes.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(t.classes.ok),
                    ),
                  ],
                ),
              );
              if (confirmed ?? false) {
                if (!context.mounted) return;
                context.router.pop();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGroupTitle(_questionGroups[_currentGroupIndex]),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (assignment.timeLimitMinutes != null)
                      TimerWidget(
                        startTime: _startTime!,
                        durationMinutes: assignment.timeLimitMinutes!,
                        onTimeUp: _handleSubmit,
                      ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () =>
                        _showQuestionNavigator(context, totalQuestions),
                    icon: const Icon(LucideIcons.grid3x3),
                    tooltip: t.submissions.doing.questionNavigator,
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Progress bar
                  LinearProgressIndicator(value: progress / 100, minHeight: 4),

                  // Question content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildGroupWidget(
                        _questionGroups[_currentGroupIndex],
                        answerState,
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
                        // Previous button
                        if (_currentGroupIndex > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _currentGroupIndex--);
                              },
                              icon: const Icon(LucideIcons.chevronLeft),
                              label: Text(t.classes.previous),
                            ),
                          ),

                        if (_currentGroupIndex > 0) const SizedBox(width: 12),

                        // Next/Submit button
                        Expanded(
                          flex: 2,
                          child: _currentGroupIndex < _questionGroups.length - 1
                              ? FilledButton.icon(
                                  onPressed: () {
                                    setState(() => _currentGroupIndex++);
                                  },
                                  icon: const Icon(LucideIcons.chevronRight),
                                  label: Text(t.classes.next),
                                )
                              : FilledButton.icon(
                                  onPressed: _handleSubmit,
                                  icon: const Icon(LucideIcons.send),
                                  label: Text(t.submissions.doing.submitButton),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loadingWidget: () => Scaffold(
          appBar: AppBar(title: Text(t.submissions.doing.title)),
          body: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (error, stack) => Scaffold(
          appBar: AppBar(title: Text(t.submissions.doing.title)),
          body: Center(child: Text(t.submissions.errors.loadFailed)),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(
    BaseQuestion question,
    AnswerEntity? currentAnswer,
  ) {
    final assignment = ref
        .read(assignmentByPostIdProvider(widget.postId!))
        .value;

    if (assignment == null) return const SizedBox.shrink();

    final answerController = ref.read(
      answerCollectionProvider(assignment).notifier,
    );

    final questionId = question.id;

    switch (question.type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceDoing(
          question: question as MultipleChoiceQuestion,
          selectedAnswer: currentAnswer is MultipleChoiceAnswerEntity
              ? currentAnswer.selectedOptionId
              : null,
          onAnswerSelected: (optionId) {
            answerController.updateAnswer(
              MultipleChoiceAnswerEntity(
                questionId: questionId,
                selectedOptionId: optionId,
              ),
            );
          },
        );

      case QuestionType.fillInBlank:
        return FillInBlankDoing(
          question: question as FillInBlankQuestion,
          answers: currentAnswer is FillInBlankAnswerEntity
              ? currentAnswer.blankAnswers
              : {},
          onAnswersChanged: (answers) {
            answerController.updateAnswer(
              FillInBlankAnswerEntity(
                questionId: questionId,
                blankAnswers: answers,
              ),
            );
          },
        );

      case QuestionType.matching:
        return MatchingDoing(
          question: question as MatchingQuestion,
          answers: currentAnswer is MatchingAnswerEntity
              ? currentAnswer.matchedPairs
              : {},
          onAnswersChanged: (pairs) {
            answerController.updateAnswer(
              MatchingAnswerEntity(questionId: questionId, matchedPairs: pairs),
            );
          },
        );

      case QuestionType.openEnded:
        return OpenEndedDoing(
          question: question as OpenEndedQuestion,
          answer: currentAnswer is OpenEndedAnswerEntity
              ? currentAnswer.response
              : null,
          onAnswerChanged: (response) {
            answerController.updateAnswer(
              OpenEndedAnswerEntity(questionId: questionId, response: response),
            );
          },
        );
    }
  }
}
