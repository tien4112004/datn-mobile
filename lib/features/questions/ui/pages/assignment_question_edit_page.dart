import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/context/context_selector_sheet.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/states/question_form/question_form_provider.dart';
import 'package:AIPrimary/features/questions/states/question_form/question_form_state.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/fill_in_blank_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/matching_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/multiple_choice_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/open_ended_section.dart';
import 'package:AIPrimary/shared/widgets/unsaved_changes_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Page for editing a question within an assignment context.
///
/// Features:
/// - Full question editing (title, content, difficulty, explanation)
/// - Points input field
/// - For bank questions: editing creates an independent copy
/// - Delete functionality
///
/// Returns updated AssignmentQuestionEntity or 'DELETE' if deleted
@RoutePage()
class AssignmentQuestionEditPage extends ConsumerStatefulWidget {
  /// The question entity to edit
  final AssignmentQuestionEntity questionEntity;

  /// Question number for display (1-indexed)
  final int questionNumber;

  const AssignmentQuestionEditPage({
    super.key,
    required this.questionEntity,
    required this.questionNumber,
  });

  @override
  ConsumerState<AssignmentQuestionEditPage> createState() =>
      _AssignmentQuestionEditPageState();
}

class _AssignmentQuestionEditPageState
    extends ConsumerState<AssignmentQuestionEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pointsController;
  late TextEditingController _titleController;
  late TextEditingController _explanationController;
  late double _currentPoints;
  late double _initialPoints;
  bool _isInitialized = false;

  /// The currently linked context entity (for display purposes).
  /// null means no context is linked.
  ContextEntity? _linkedContext;
  String? _currentContextId;
  bool _contextChanged = false;
  bool _contextExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.questionEntity.points;
    _initialPoints = widget.questionEntity.points;
    _pointsController = TextEditingController(
      text: _currentPoints.toStringAsFixed(0),
    );
    _titleController = TextEditingController(
      text: widget.questionEntity.question.title,
    );
    _explanationController = TextEditingController(
      text: widget.questionEntity.question.explanation ?? '',
    );

    _currentContextId = widget.questionEntity.contextId;

    _pointsController.addListener(() {
      final newValue = double.tryParse(_pointsController.text) ?? 0.0;
      setState(() => _currentPoints = newValue);
    });

    // Initialize form state with question data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(questionFormProvider.notifier)
          .initializeFromBaseQuestion(widget.questionEntity.question);
      setState(() => _isInitialized = true);
    });
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _titleController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  bool get _hasAnyUnsavedChanges {
    final pointsChanged = _currentPoints != _initialPoints;
    final contentChanged = ref.read(hasUnsavedChangesProvider);
    return pointsChanged || contentChanged || _contextChanged;
  }

  Future<bool> _onWillPop() async {
    if (!_hasAnyUnsavedChanges) return true;

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
    final t = ref.read(translationsPod);
    // Validate points
    if (_currentPoints <= 0) {
      _showErrorSnackBar(t.assignments.pointsError);
      return;
    }

    // Validate form
    final formState = ref.read(questionFormProvider);
    final validationError = formState.validate();
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    // Check if content was modified
    final contentWasModified = ref.read(hasUnsavedChangesProvider);

    // Create question from form state
    final updatedQuestion = _createQuestionFromFormState(formState);

    // Create updated entity
    // If content was modified on a bank question, it becomes a new question
    final updatedEntity = widget.questionEntity.copyWith(
      question: updatedQuestion,
      points: _currentPoints,
      isNewQuestion: widget.questionEntity.isNewQuestion || contentWasModified,
      questionBankId: contentWasModified
          ? null
          : widget.questionEntity.questionBankId,
      contextId: _currentContextId,
      clearContextId: _currentContextId == null,
    );

    ref.read(questionFormProvider.notifier).markSaved();
    Navigator.pop(context, updatedEntity);
  }

  BaseQuestion _createQuestionFromFormState(QuestionFormState formState) {
    // Generate a new temporary ID if content was modified (making it a copy)
    final contentWasModified = ref.read(hasUnsavedChangesProvider);
    final questionId = contentWasModified
        ? 'new_${DateTime.now().millisecondsSinceEpoch}'
        : widget.questionEntity.question.id;

    switch (formState.type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestion(
          id: questionId,
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
                    id: 'opt_${questionId}_${entry.key}',
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
          id: questionId,
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
                    id: 'pair_${questionId}_${entry.key}',
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
          id: questionId,
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
                    id: 'seg_${questionId}_${entry.key}',
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
          id: questionId,
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

  Future<void> _handleDelete() async {
    final t = ref.read(translationsPod);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          icon: Icon(LucideIcons.circle, color: colorScheme.error, size: 32),
          title: Text(t.questionBank.deleteDialog.title),
          content: Text(
            'Are you sure you want to remove question ${widget.questionNumber} from this assignment?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.common.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: Text(t.common.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      // Return special value to indicate deletion
      Navigator.pop(context, 'DELETE');
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
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formState = ref.watch(questionFormProvider);
    final hasUnsavedChanges = ref.watch(hasUnsavedChangesProvider);
    final hasAnyChanges = _hasAnyUnsavedChanges || hasUnsavedChanges;

    // Show loading while form is initializing
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            t.questionBank.editQuestionTitle(
              number: widget.questionNumber.toString(),
            ),
          ),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.router.maybePop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !hasAnyChanges,
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
        appBar: AppBar(
          title: Text(
            t.questionBank.editQuestionTitle(
              number: widget.questionNumber.toString(),
            ),
          ),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () async {
              final router = context.router;
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                router.maybePop();
              }
            },
          ),
          actions: [
            // Delete button
            IconButton(
              icon: Icon(LucideIcons.trash2, color: colorScheme.error),
              onPressed: _handleDelete,
              tooltip: t.questionBank.actions.delete,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Points field
                TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: t.common.points,
                    suffixText: 'pts',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Reading Passage section
                _buildContextSection(theme, colorScheme),
                const SizedBox(height: 20),

                // Question Title field
                TextField(
                  controller: _titleController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: t.questionBank.form.questionImage,
                    hintText: t.questionBank.form.titleHint,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(questionFormProvider.notifier).updateTitle(value);
                  },
                ),
                const SizedBox(height: 20),

                // Type & Difficulty row
                Row(
                  children: [
                    // Question Type (read-only chip)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: QuestionType.getColor(
                          formState.type,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: QuestionType.getColor(
                            formState.type,
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            QuestionType.getIcon(formState.type),
                            size: 16,
                            color: QuestionType.getColor(formState.type),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formState.type.getLocalizedName(t),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: QuestionType.getColor(formState.type),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Difficulty Selector
                    Expanded(
                      child: DropdownButtonFormField<Difficulty>(
                        initialValue: formState.difficulty,
                        decoration: InputDecoration(
                          labelText: t.common.difficulty,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: Difficulty.values.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty.getLocalizedName(t)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(questionFormProvider.notifier)
                                .updateDifficulty(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Type-specific section
                _buildTypeSpecificSection(formState),
                const SizedBox(height: 24),

                // Explanation field
                TextField(
                  controller: _explanationController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '${t.common.explanation} ${t.common.optional}',
                    hintText: t.questionBank.form.explanationHint,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(questionFormProvider.notifier)
                        .updateExplanation(value);
                  },
                ),

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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final router = context.router;
                      final shouldPop = await _onWillPop();
                      if (shouldPop && context.mounted) {
                        router.maybePop();
                      }
                    },
                    child: Text(t.common.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: hasAnyChanges ? _handleSave : null,
                    icon: const Icon(LucideIcons.check, size: 20),
                    label: Text(t.students.saveChanges),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextSection(ThemeData theme, ColorScheme colorScheme) {
    if (_currentContextId != null) {
      final hasContent =
          _linkedContext != null && _linkedContext!.content.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: Colors.blue.shade400, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row — tappable to expand/collapse
            InkWell(
              onTap: hasContent
                  ? () => setState(() => _contextExpanded = !_contextExpanded)
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.bookOpen,
                      size: 20,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reading Passage',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_linkedContext != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _linkedContext!.title.isNotEmpty
                                  ? _linkedContext!.title
                                  : 'Untitled Passage',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue.shade700,
                              ),
                              maxLines: _contextExpanded ? null : 1,
                              overflow: _contextExpanded
                                  ? null
                                  : TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasContent)
                      Icon(
                        _contextExpanded
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: 18,
                        color: Colors.blue.shade600,
                      ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.unlink,
                        size: 18,
                        color: colorScheme.error,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentContextId = null;
                          _linkedContext = null;
                          _contextChanged = true;
                          _contextExpanded = false;
                        });
                      },
                      tooltip: 'Unlink passage',
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            if (_contextExpanded && hasContent)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _linkedContext!.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Show "Link passage" button
    return OutlinedButton.icon(
      onPressed: () async {
        final selected = await ContextSelectorSheet.show(context);
        if (selected != null && mounted) {
          setState(() {
            _linkedContext = selected;
            _currentContextId = selected.id;
            _contextChanged = true;
          });
        }
      },
      icon: Icon(LucideIcons.bookOpen, size: 18, color: Colors.blue.shade600),
      label: Text(
        'Link Reading Passage',
        style: TextStyle(color: Colors.blue.shade600),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.blue.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
