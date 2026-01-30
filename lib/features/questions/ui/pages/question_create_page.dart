import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_create_request_entity.dart';
import 'package:AIPrimary/features/questions/states/question_bank_provider.dart';
import 'package:AIPrimary/features/questions/states/question_form/question_form_provider.dart';
import 'package:AIPrimary/features/questions/states/question_form/question_form_state.dart';
import 'package:AIPrimary/features/questions/ui/widgets/chapter_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/ui/widgets/modify/question_meta_row.dart';
import 'package:AIPrimary/features/questions/ui/widgets/modify/question_title_input.dart';
import 'package:AIPrimary/features/questions/ui/widgets/modify/question_advanced_options.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/multiple_choice_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/matching_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/open_ended_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/fill_in_blank_section.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:AIPrimary/shared/widgets/unsaved_changes_dialog.dart';
import 'package:AIPrimary/shared/widgets/form_action_buttons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page for creating a new question
@RoutePage()
class QuestionCreatePage extends ConsumerStatefulWidget {
  const QuestionCreatePage({super.key});

  @override
  ConsumerState<QuestionCreatePage> createState() => _QuestionCreatePageState();
}

class _QuestionCreatePageState extends ConsumerState<QuestionCreatePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize form state for new question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionFormProvider.notifier).initializeForCreate();
    });
  }

  @override
  void dispose() {
    // Invalidate the provider to ensure state is reset when page is closed
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

  void _handleSave() async {
    // Validate using provider's validation method
    final formState = ref.read(questionFormProvider);
    final validationError = formState.validate();

    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    try {
      await ref
          .read(questionBankProvider.notifier)
          .createQuestion(
            QuestionCreateRequestEntity(
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
          title: 'Create Question',
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
              // 1. Meta Row (Grade, Subject, Level)
              QuestionMetaRow(
                grade: formState.grade,
                subject: formState.subject,
                difficulty: formState.difficulty,
                onGradeChanged: (value) =>
                    ref.read(questionFormProvider.notifier).updateGrade(value),
                onSubjectChanged: (value) => ref
                    .read(questionFormProvider.notifier)
                    .updateSubject(value),
                onDifficultyChanged: (value) => ref
                    .read(questionFormProvider.notifier)
                    .updateDifficulty(value),
              ),
              const SizedBox(height: 16),

              // 2. Question Title & Image
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
                  DropdownButton<QuestionType>(
                    value: formState.type,
                    underline: Container(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.primary,
                    ),
                    items: QuestionType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(questionFormProvider.notifier).updateType(val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 3. Answer Options (Type Specific Section)
              _buildTypeSpecificSection(formState),
              const SizedBox(height: 24),

              // 4. Advanced Options
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
                isEditing: false,
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
