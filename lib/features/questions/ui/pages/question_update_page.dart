import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_update_request_entity.dart';
import 'package:datn_mobile/features/questions/states/question_bank_provider.dart';
import 'package:datn_mobile/features/questions/states/question_form/question_form_provider.dart';
import 'package:datn_mobile/features/questions/states/question_form/question_form_state.dart';
import 'package:datn_mobile/features/questions/ui/widgets/chapter_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/features/questions/ui/widgets/modify/question_meta_row.dart';
import 'package:datn_mobile/features/questions/ui/widgets/modify/question_title_input.dart';
import 'package:datn_mobile/features/questions/ui/widgets/modify/question_advanced_options.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/multiple_choice_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/matching_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/open_ended_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/fill_in_blank_section.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:datn_mobile/shared/widgets/unsaved_changes_dialog.dart';
import 'package:datn_mobile/shared/widgets/form_action_buttons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page for creating or editing a question
@RoutePage()
class QuestionUpdatePage extends ConsumerStatefulWidget {
  /// Question ID if editing, null if creating new
  final String questionId;

  const QuestionUpdatePage({super.key, required this.questionId});

  @override
  ConsumerState<QuestionUpdatePage> createState() => _QuestionModifyPageState();
}

class _QuestionModifyPageState extends ConsumerState<QuestionUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  // This is always an edit page
  bool get _isEditing => true;

  @override
  void initState() {
    super.initState();

    // Initialize form state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestion();
    });
  }

  @override
  void dispose() {
    // Invalidate the provider to ensure state is reset when page is closed
    super.dispose();
  }

  Future<void> _loadQuestion() async {
    // Load the question from the bank if not already loaded
    await ref
        .read(questionBankProvider.notifier)
        .getQuestionById(widget.questionId);

    // Get the loaded question - read the state again after the async operation
    final questionBankState = ref.read(questionBankProvider);
    questionBankState.whenData((state) {
      if (state.selectedQuestion != null) {
        final questionItem = state.selectedQuestion!;
        final question = questionItem.question;
        // Convert question data to Map<String, dynamic>
        Map<String, dynamic> data = {};
        if (question is MultipleChoiceQuestion) {
          data = {
            'options': question.data.options
                .map(
                  (opt) => {
                    'text': opt.text,
                    'imageUrl': opt.imageUrl,
                    'isCorrect': opt.isCorrect,
                  },
                )
                .toList(),
            'shuffleOptions': question.data.shuffleOptions,
          };
        } else if (question is MatchingQuestion) {
          data = {
            'pairs': question.data.pairs
                .map(
                  (pair) => {
                    'leftText': pair.left,
                    'leftImageUrl': pair.leftImageUrl,
                    'rightText': pair.right,
                    'rightImageUrl': pair.rightImageUrl,
                  },
                )
                .toList(),
            'shufflePairs': question.data.shufflePairs,
          };
        } else if (question is OpenEndedQuestion) {
          data = {
            'expectedAnswer': question.data.expectedAnswer,
            'maxLength': question.data.maxLength,
          };
        } else if (question is FillInBlankQuestion) {
          data = {
            'segments': question.data.segments
                .map(
                  (seg) => {
                    'type': seg.type == SegmentType.blank ? 'blank' : 'text',
                    'content': seg.content,
                    'acceptableAnswers': seg.acceptableAnswers,
                  },
                )
                .toList(),
            'caseSensitive': question.data.caseSensitive,
          };
        }

        // Initialize form with question data
        ref
            .read(questionFormProvider.notifier)
            .initializeForEdit(
              questionItem.id,
              title: question.title,
              type: question.type,
              difficulty: question.difficulty,
              titleImageUrl: question.titleImageUrl,
              explanation: question.explanation,
              grade: questionItem.grade?.apiValue,
              chapter: questionItem.chapter,
              subject: questionItem.subject?.apiValue,
              data: data,
            );

        setState(() {});
      }
    });
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

  void _handleSave() async {
    // Validate using provider's validation method
    final formState = ref.read(questionFormProvider);
    final validationError = formState.validate();

    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    try {
      debugPrint('Saving question with ID: ${widget.questionId}');

      await ref
          .read(questionBankProvider.notifier)
          .updateQuestion(
            widget.questionId,
            QuestionUpdateRequestEntity(
              title: formState.title,
              explanation: formState.explanation,
              type: formState.type,
              difficulty: formState.difficulty,
              titleImageUrl: formState.titleImageUrl,
              data: formState.getDataPayload(),
              grade: formState.grade,
              chapter: formState.chapter,
              subject: formState.subject,
            ),
          );

      // Mark as saved and navigate back
      ref.read(questionFormProvider.notifier).markSaved();
      if (mounted) {
        context.router.pop();
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error saving question: $e');
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

  Future<void> _handleChapterSelection() async {
    final formState = ref.read(questionFormProvider);

    // Parse grade and subject from string to enum
    GradeLevel? grade;
    Subject? subject;

    try {
      grade = GradeLevel.values.firstWhere(
        (g) => g.apiValue == formState.grade.apiValue,
      );
    } catch (e) {
      // Grade not found
    }

    try {
      subject = Subject.values.firstWhere(
        (s) => s.apiValue == formState.subject.apiValue,
      );
    } catch (e) {
      // Subject not found
    }

    final selectedChapter = await ChapterSelectionDialog.show(
      context,
      grade: grade,
      subject: subject,
      currentChapterId: formState.chapter,
    );

    if (selectedChapter != null) {
      ref.read(questionFormProvider.notifier).updateChapter(selectedChapter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formState = ref.watch(questionFormProvider);
    final hasUnsavedChanges = ref.watch(hasUnsavedChangesProvider);
    final questionBankState = ref.watch(questionBankProvider);

    // Show loading while fetching question data in edit mode
    if (_isEditing && questionBankState.isLoading && formState.title.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: CustomAppBar(
          title: 'Edit Question',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.maybePop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          title: 'Edit Question',
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
              tooltip: 'Save',
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              QuestionMetaRow(
                grade: formState.grade,
                subject: formState.subject,
                difficulty: formState.difficulty,
                canEdit: false,
                onGradeChanged: null,
                onSubjectChanged: null,
                onDifficultyChanged: (value) => ref
                    .read(questionFormProvider.notifier)
                    .updateDifficulty(value),
              ),
              const SizedBox(height: 16),

              QuestionTitleInput(
                title: formState.title,
                onTitleChanged: (value) =>
                    ref.read(questionFormProvider.notifier).updateTitle(value),
                titleImageUrl: formState.titleImageUrl,
                onTitleImageChanged: (value) => ref
                    .read(questionFormProvider.notifier)
                    .updateTitleImageUrl(value),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Type: ",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formState.type.displayName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _buildTypeSpecificSection(formState),
              const SizedBox(height: 24),

              QuestionAdvancedOptions(
                chapter: formState.chapter,
                explanation: formState.explanation,
                onExplanationChanged: (value) => ref
                    .read(questionFormProvider.notifier)
                    .updateExplanation(value),
                onChapterButtonPressed: _handleChapterSelection,
              ),

              const SizedBox(height: 32),

              // Bottom action buttons
              FormActionButtons(
                isLoading: formState.isLoading,
                isEditing: _isEditing,
                onCancel: () async {
                  final router = context.router;
                  final shouldPop = await _onWillPop();
                  if (shouldPop && mounted) {
                    router.maybePop();
                  }
                },
                onSave: _handleSave,
              ),
              const SizedBox(height: 16),
            ],
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
