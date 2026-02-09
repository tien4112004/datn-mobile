import 'package:AIPrimary/core/router/router.gr.dart';
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
  int _currentQuestionIndex = 0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  Future<void> _handleSubmit() async {
    final t = ref.read(translationsPod);

    if (widget.postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error: Missing postId parameter'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final assignmentAsync = ref.read(
      assignmentPublicProvider(widget.assignmentId),
    );

    final assignment = assignmentAsync.value;
    if (assignment == null) return;

    final answerController = ref.read(
      answerCollectionProvider(assignment).notifier,
    );

    // Validate all questions answered
    final unanswered = answerController.validateAnswers();

    if (unanswered.isNotEmpty) {
      // Show incomplete warning
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.submissions.doing.incompleteWarning),
          content: Text(
            'Questions ${unanswered.map((i) => i + 1).join(", ")} are not answered.',
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

      // Navigate back to preview page to show the result
      context.router.replace(
        AssignmentPreviewRoute(
          assignmentId: assignmentAsync.value!.assignmentId,
          postId: widget.postId!,
        ),
      );
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
        .read(assignmentPublicProvider(widget.assignmentId))
        .value;

    if (assignment == null) return;

    final answerState = ref.read(answerCollectionProvider(assignment));

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: QuestionNavigator(
          currentIndex: _currentQuestionIndex,
          totalQuestions: totalQuestions,
          answeredQuestions: answerState.answers.keys.where((qId) {
            final answer = answerState.answers[qId];
            return answer?.isAnswered ?? false;
          }).toList(),
          onQuestionSelected: (index) {
            setState(() => _currentQuestionIndex = index);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final assignmentAsync = ref.watch(
      assignmentPublicProvider(widget.assignmentId),
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
              body: const Center(child: Text('No questions in assignment')),
            );
          }

          final currentQuestion = assignment.questions[_currentQuestionIndex];
          final progress = answerState.progress;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t.classes.warning),
                  content: const Text(
                    'Are you sure you want to leave? Your progress will not be saved.',
                  ),
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
                      '${t.submissions.doing.title} ${_currentQuestionIndex + 1}/$totalQuestions',
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
                      child: _buildQuestionWidget(
                        currentQuestion.question.type,
                        currentQuestion.question.id,
                        answerState.answers[currentQuestion.question.id],
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
                        if (_currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _currentQuestionIndex--);
                              },
                              icon: const Icon(LucideIcons.chevronLeft),
                              label: Text(t.classes.previous),
                            ),
                          ),

                        if (_currentQuestionIndex > 0)
                          const SizedBox(width: 12),

                        // Next/Submit button
                        Expanded(
                          flex: 2,
                          child: _currentQuestionIndex < totalQuestions - 1
                              ? FilledButton.icon(
                                  onPressed: () {
                                    setState(() => _currentQuestionIndex++);
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
    QuestionType type,
    String questionId,
    AnswerEntity? currentAnswer,
  ) {
    final assignment = ref
        .read(assignmentPublicProvider(widget.assignmentId))
        .value;

    if (assignment == null) return const SizedBox.shrink();

    final assignmentQuestion = assignment.questions.firstWhere(
      (q) => q.question.id == questionId,
    );
    final question = assignmentQuestion.question;

    final answerController = ref.read(
      answerCollectionProvider(assignment).notifier,
    );

    switch (type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceDoing(
          question: question as dynamic,
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
          question: question as dynamic,
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
          question: question as dynamic,
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
          question: question as dynamic,
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
