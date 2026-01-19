import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_create_request_entity.dart';
import 'package:datn_mobile/features/questions/states/question_bank_provider.dart';
import 'package:datn_mobile/features/questions/states/question_form/question_form_provider.dart';
import 'package:datn_mobile/features/questions/states/question_form/question_form_state.dart';
import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/question_basic_info_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/multiple_choice_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/matching_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/open_ended_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/fill_in_blank_section.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:datn_mobile/shared/widget/unsaved_changes_dialog.dart';
import 'package:datn_mobile/shared/widget/form_action_buttons.dart';
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
      ref.read(questionFormProvider.notifier).setLoading(true);

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
    } finally {
      if (mounted) {
        ref.read(questionFormProvider.notifier).setLoading(false);
      }
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
            padding: const EdgeInsets.all(16),
            children: [
              // Basic information section
              QuestionBasicInfoSection(
                key: ValueKey(formState.questionId),
                title: formState.title,
                selectedType: formState.type,
                selectedDifficulty: formState.difficulty,
                titleImageUrl: formState.titleImageUrl,
                explanation: formState.explanation,
                grade: formState.grade,
                chapter: formState.chapter,
                subject: formState.subject,
                onTitleChanged: (value) {
                  ref.read(questionFormProvider.notifier).updateTitle(value);
                },
                onTypeChanged: (type) {
                  ref.read(questionFormProvider.notifier).updateType(type);
                },
                onDifficultyChanged: (difficulty) {
                  ref
                      .read(questionFormProvider.notifier)
                      .updateDifficulty(difficulty);
                },
                onTitleImageChanged: (url) {
                  ref
                      .read(questionFormProvider.notifier)
                      .updateTitleImageUrl(url);
                },
                onExplanationChanged: (value) {
                  ref
                      .read(questionFormProvider.notifier)
                      .updateExplanation(value);
                },
                onGradeChanged: (value) {
                  ref.read(questionFormProvider.notifier).updateGrade(value);
                },
                onChapterChanged: (value) {
                  ref.read(questionFormProvider.notifier).updateChapter(value);
                },
                onSubjectChanged: (value) {
                  ref.read(questionFormProvider.notifier).updateSubject(value);
                },
              ),
              const SizedBox(height: 32),

              // Type-specific section
              _buildTypeSpecificSection(formState),

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
