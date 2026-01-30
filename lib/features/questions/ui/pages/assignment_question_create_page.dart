import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/states/question_form/question_form_provider.dart';
import 'package:AIPrimary/features/questions/states/question_form/question_form_state.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/fill_in_blank_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/matching_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/multiple_choice_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/open_ended_section.dart';
import 'package:AIPrimary/shared/widgets/unsaved_changes_dialog.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Page for creating a new question specifically for an assignment.
///
/// Features:
/// - Full question creation form
/// - Points input field
/// - Returns AssignmentQuestionEntity (not saved to question bank)
/// - Used when teachers want to create assignment-specific questions
@RoutePage()
class AssignmentQuestionCreatePage extends ConsumerStatefulWidget {
  /// Default points value for the question
  final double defaultPoints;

  const AssignmentQuestionCreatePage({super.key, this.defaultPoints = 10.0});

  @override
  ConsumerState<AssignmentQuestionCreatePage> createState() =>
      _AssignmentQuestionCreatePageState();
}

class _AssignmentQuestionCreatePageState
    extends ConsumerState<AssignmentQuestionCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pointsController;
  late double _currentPoints;

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.defaultPoints;
    _pointsController = TextEditingController(
      text: _currentPoints.toStringAsFixed(0),
    );

    _pointsController.addListener(() {
      final newValue = double.tryParse(_pointsController.text) ?? 0.0;
      setState(() => _currentPoints = newValue);
    });

    // Initialize form state for new question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionFormProvider.notifier).initializeForCreate();
    });
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final hasUnsavedChanges = ref.read(hasUnsavedChangesProvider);
    if (!hasUnsavedChanges) return true;

    final result = await UnsavedChangesDialog.show(
      context,
      onDiscard: () {
        ref.read(questionFormProvider.notifier).markSaved();
        context.router.pop();
      },
    );
    return result ?? false;
  }

  void _handleSave() {
    // Validate points
    if (_currentPoints <= 0) {
      _showErrorSnackBar('Points must be greater than 0');
      return;
    }

    // Validate using provider's validation method
    final formState = ref.read(questionFormProvider);
    final validationError = formState.validate();

    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    // Create BaseQuestion from form state
    final BaseQuestion question = _createQuestionFromFormState(formState);

    // Create AssignmentQuestionEntity
    final assignmentQuestion = AssignmentQuestionEntity(
      questionBankId: null, // New question, not from bank
      question: question,
      points: _currentPoints,
      isNewQuestion: true,
    );

    // Mark as saved and return the question entity
    ref.read(questionFormProvider.notifier).markSaved();
    Navigator.pop(context, assignmentQuestion);
  }

  BaseQuestion _createQuestionFromFormState(QuestionFormState formState) {
    // Generate a temporary ID for the new question
    final tempId = 'new_${DateTime.now().millisecondsSinceEpoch}';

    switch (formState.type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestion(
          id: tempId,
          title: formState.title,
          difficulty: formState.difficulty,
          titleImageUrl: formState.titleImageUrl,
          explanation: formState.explanation,
          data: MultipleChoiceData(
            options: formState.multipleChoiceOptions
                .asMap()
                .entries
                .map(
                  (entry) => MultipleChoiceOption(
                    id: 'opt_${tempId}_${entry.key}',
                    text: entry.value.text,
                    imageUrl: entry.value.imageUrl,
                    isCorrect: entry.value.isCorrect,
                  ),
                )
                .toList(),
            shuffleOptions: formState.shuffleOptions,
          ),
        );

      case QuestionType.matching:
        return MatchingQuestion(
          id: tempId,
          title: formState.title,
          difficulty: formState.difficulty,
          titleImageUrl: formState.titleImageUrl,
          explanation: formState.explanation,
          data: MatchingData(
            pairs: formState.matchingPairs
                .asMap()
                .entries
                .map(
                  (entry) => MatchingPair(
                    id: 'pair_${tempId}_${entry.key}',
                    left: entry.value.leftText,
                    leftImageUrl: entry.value.leftImageUrl,
                    right: entry.value.rightText,
                    rightImageUrl: entry.value.rightImageUrl,
                  ),
                )
                .toList(),
            shufflePairs: formState.shufflePairs,
          ),
        );

      case QuestionType.fillInBlank:
        return FillInBlankQuestion(
          id: tempId,
          title: formState.title,
          difficulty: formState.difficulty,
          titleImageUrl: formState.titleImageUrl,
          explanation: formState.explanation,
          data: FillInBlankData(
            segments: formState.segments
                .asMap()
                .entries
                .map(
                  (entry) => BlankSegment(
                    id: 'seg_${tempId}_${entry.key}',
                    type: entry.value.type,
                    content: entry.value.content,
                    acceptableAnswers: entry.value.acceptableAnswers,
                  ),
                )
                .toList(),
            caseSensitive: formState.caseSensitive,
          ),
        );

      case QuestionType.openEnded:
        return OpenEndedQuestion(
          id: tempId,
          title: formState.title,
          difficulty: formState.difficulty,
          titleImageUrl: formState.titleImageUrl,
          explanation: formState.explanation,
          data: OpenEndedData(
            expectedAnswer: formState.expectedAnswer,
            maxLength: formState.maxLength,
          ),
        );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formState = ref.watch(questionFormProvider);
    final hasUnsavedChanges = ref.watch(hasUnsavedChangesProvider);

    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final router = context.router;
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            router.maybePop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: CustomAppBar(
          title: 'Create Question for Assignment',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final router = context.router;
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                router.maybePop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _handleSave,
              tooltip: 'Add to Assignment',
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This question will be created for this assignment only',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Points Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.target,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Points',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _pointsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Points for this question',
                            suffixText: 'pts',
                            helperText: 'Points must be greater than 0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(LucideIcons.hash),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // // Basic Information Section
                // QuestionBasicInfoSection(
                //   title: formState.title,
                //   selectedType: formState.type,
                //   selectedDifficulty: formState.difficulty,
                //   titleImageUrl: formState.titleImageUrl,
                //   explanation: formState.explanation,
                //   grade: formState.grade,
                //   chapter: formState.chapter,
                //   subject: formState.subject,
                //   onTitleChanged: (value) {
                //     ref.read(questionFormProvider.notifier).updateTitle(value);
                //   },
                //   onTypeChanged: (type) {
                //     ref.read(questionFormProvider.notifier).updateType(type);
                //   },
                //   onDifficultyChanged: (difficulty) {
                //     ref
                //         .read(questionFormProvider.notifier)
                //         .updateDifficulty(difficulty);
                //   },
                //   onTitleImageChanged: (url) {
                //     ref
                //         .read(questionFormProvider.notifier)
                //         .updateTitleImageUrl(url);
                //   },
                //   onExplanationChanged: (value) {
                //     ref
                //         .read(questionFormProvider.notifier)
                //         .updateExplanation(value);
                //   },
                //   onGradeChanged: (value) {
                //     ref.read(questionFormProvider.notifier).updateGrade(value);
                //   },
                //   onChapterChanged: (value) {
                //     ref
                //         .read(questionFormProvider.notifier)
                //         .updateChapter(value);
                //   },
                //   onSubjectChanged: (value) {
                //     ref
                //         .read(questionFormProvider.notifier)
                //         .updateSubject(value);
                //   },
                // ),
                const SizedBox(height: 16),

                // Type-specific sections
                _buildTypeSpecificSection(formState),

                const SizedBox(height: 80), // Space for bottom button
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                offset: const Offset(0, -4),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: FilledButton.icon(
              onPressed: _handleSave,
              icon: const Icon(LucideIcons.plus, size: 20),
              label: const Text('Add to Assignment'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificSection(QuestionFormState formState) {
    final notifier = ref.read(questionFormProvider.notifier);

    switch (formState.type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceSection(
          options: formState.multipleChoiceOptions,
          shuffleOptions: formState.shuffleOptions,
          onOptionsChanged: notifier.updateMultipleChoiceOptions,
          onShuffleChanged: notifier.updateShuffleOptions,
        );

      case QuestionType.matching:
        return MatchingSection(
          pairs: formState.matchingPairs,
          shufflePairs: formState.shufflePairs,
          onPairsChanged: notifier.updateMatchingPairs,
          onShuffleChanged: notifier.updateShufflePairs,
        );

      case QuestionType.openEnded:
        return OpenEndedSection(
          expectedAnswer: formState.expectedAnswer,
          maxLength: formState.maxLength,
          onExpectedAnswerChanged: notifier.updateExpectedAnswer,
          onMaxLengthChanged: notifier.updateMaxLength,
        );

      case QuestionType.fillInBlank:
        return FillInBlankSection(
          segments: formState.segments,
          caseSensitive: formState.caseSensitive,
          onSegmentsChanged: notifier.updateSegments,
          onCaseSensitiveChanged: notifier.updateCaseSensitive,
        );
    }
  }
}
