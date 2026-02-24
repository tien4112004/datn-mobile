import 'package:AIPrimary/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/picker_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/assignments/domain/entity/api_matrix_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/context/local_context_selector_sheet.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/states/question_form/question_form_provider.dart';
import 'package:AIPrimary/features/questions/states/question_form/question_form_state.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/fill_in_blank_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/matching_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/multiple_choice_section.dart';
import 'package:AIPrimary/features/questions/ui/pages/modify/open_ended_section.dart';
import 'package:AIPrimary/features/questions/ui/widgets/modify/question_title_input.dart';
import 'package:AIPrimary/shared/widgets/unsaved_changes_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Page for creating a new question specifically for an assignment.
///
/// Features:
/// - Two tabs: Metadata (points, subtopic, info) and Content (context, type-specific, explanation)
/// - Points input field
/// - Returns AssignmentQuestionEntity (not saved to question bank)
/// - Used when teachers want to create assignment-specific questions
@RoutePage()
class AssignmentQuestionCreatePage extends ConsumerStatefulWidget {
  /// Default points value for the question
  final double defaultPoints;

  /// Local contexts available in this assignment for linking
  final List<ContextEntity> assignmentContexts;

  /// Available topics from the assignment matrix for topic assignment
  final List<MatrixDimensionTopic> availableTopics;

  const AssignmentQuestionCreatePage({
    super.key,
    this.defaultPoints = 10.0,
    this.assignmentContexts = const [],
    this.availableTopics = const [],
  });

  @override
  ConsumerState<AssignmentQuestionCreatePage> createState() =>
      _AssignmentQuestionCreatePageState();
}

class _AssignmentQuestionCreatePageState
    extends ConsumerState<AssignmentQuestionCreatePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  late TextEditingController _pointsController;
  late double _currentPoints;

  ContextEntity? _linkedContext;
  String? _currentContextId;
  String? _currentTopicId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
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
    final t = ref.read(translationsPod);
    // Validate points
    if (_currentPoints <= 0) {
      _showErrorSnackBar(t.assignments.pointsError);
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
      contextId: _currentContextId,
      topicId: _currentTopicId,
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
    final t = ref.watch(translationsPod);
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
        appBar: AppBar(
          title: Text(t.questionBank.createQuestion),
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
              tooltip: t.questionBank.form.addToAssignment,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: const Icon(LucideIcons.settings2, size: 18),
                text: t.assignments.metadataTab,
              ),
              Tab(
                icon: const Icon(LucideIcons.fileText, size: 18),
                text: t.assignments.contentTab,
              ),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMetadataTab(theme, colorScheme, formState),
              _buildContentTab(theme, colorScheme, formState),
            ],
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
              label: Text(t.questionBank.form.addToAssignment),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Metadata Tab ──────────────────────────────────────────────────────

  Widget _buildMetadataTab(
    ThemeData theme,
    ColorScheme colorScheme,
    QuestionFormState formState,
  ) {
    final t = ref.watch(translationsPod);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    t.questionBank.infoText,
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
                        t.common.points,
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
                      labelText: t.questionBank.form.pointsHint,
                      suffixText: t.common.pointsSuffix,
                      helperText: t.assignments.pointsError,
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
          const SizedBox(height: 20),

          // Type & Difficulty row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Type selector
              Expanded(
                child: SettingItem(
                  label: t.questionBank.form.type,
                  child: PickerButton(
                    label: formState.type.getLocalizedName(t),
                    onTap: () =>
                        GeneralPickerOptions.showEnumPicker<QuestionType>(
                          context: context,
                          title: t.questionBank.form.type,
                          values: QuestionType.values,
                          labelOf: (type) => type.getLocalizedName(t),
                          isSelected: (type) => type == formState.type,
                          onSelected: (value) => ref
                              .read(questionFormProvider.notifier)
                              .updateType(value),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Difficulty selector
              Expanded(
                child: SettingItem(
                  label: t.common.difficulty,
                  child: PickerButton(
                    label: formState.difficulty.getLocalizedName(t),
                    onTap: () =>
                        GeneralPickerOptions.showEnumPicker<Difficulty>(
                          context: context,
                          title: t.common.difficulty,
                          values: Difficulty.values,
                          labelOf: (d) => d.getLocalizedName(t),
                          isSelected: (d) => d == formState.difficulty,
                          onSelected: (value) => ref
                              .read(questionFormProvider.notifier)
                              .updateDifficulty(value),
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Topic selector
          if (widget.availableTopics.isNotEmpty)
            _buildTopicSelector(theme, colorScheme),
        ],
      ),
    );
  }

  // ── Content Tab ───────────────────────────────────────────────────────

  Widget _buildContentTab(
    ThemeData theme,
    ColorScheme colorScheme,
    QuestionFormState formState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reading Passage section
          if (widget.assignmentContexts.isNotEmpty)
            _buildContextSection(theme, colorScheme),
          if (widget.assignmentContexts.isNotEmpty) const SizedBox(height: 16),

          // Question Title with image button
          QuestionTitleInput(
            title: formState.title,
            onTitleChanged: (value) =>
                ref.read(questionFormProvider.notifier).updateTitle(value),
            titleImageUrl: formState.titleImageUrl,
            onTitleImageChanged: (value) => ref
                .read(questionFormProvider.notifier)
                .updateTitleImageUrl(value),
          ),
          const SizedBox(height: 24),

          // Type-specific sections
          _buildTypeSpecificSection(formState),

          const SizedBox(height: 80), // Space for bottom button
        ],
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────

  Widget _buildTopicSelector(ThemeData theme, ColorScheme colorScheme) {
    final t = ref.watch(translationsPod);
    final selectedName = _currentTopicId == null || _currentTopicId!.isEmpty
        ? t.common.none
        : widget.availableTopics
              .firstWhere(
                (top) => top.id == _currentTopicId,
                orElse: () => widget.availableTopics.first,
              )
              .name;

    return SettingItem(
      label: t.assignments.subtopic,
      child: PickerButton(
        label: selectedName,
        onTap: () => PickerBottomSheet.show(
          context: context,
          title: t.assignments.subtopic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(t.common.none),
                trailing: (_currentTopicId == null || _currentTopicId!.isEmpty)
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() => _currentTopicId = null);
                  Navigator.pop(context);
                },
              ),
              ...widget.availableTopics.map(
                (topic) => ListTile(
                  title: Text(topic.name),
                  trailing: _currentTopicId == topic.id
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() => _currentTopicId = topic.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextSection(ThemeData theme, ColorScheme colorScheme) {
    final t = ref.watch(translationsPod);

    if (_currentContextId != null && _linkedContext != null) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: colorScheme.primary, width: 3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(LucideIcons.bookOpen, size: 20, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.assignments.context.readingPassage,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _linkedContext!.title.isNotEmpty
                          ? _linkedContext!.title
                          : t.assignments.context.untitledPassage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
                  });
                },
                tooltip: t.assignments.context.unlinkPassage,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ],
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () async {
        final selected = await LocalContextSelectorSheet.show(
          context,
          contexts: widget.assignmentContexts,
          currentContextId: _currentContextId,
        );
        if (selected != null && mounted) {
          setState(() {
            _linkedContext = selected;
            _currentContextId = selected.id;
          });
        }
      },
      icon: Icon(LucideIcons.bookOpen, size: 18, color: colorScheme.primary),
      label: Text(
        t.assignments.context.linkReadingPassage,
        style: TextStyle(color: colorScheme.primary),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colorScheme.primary),
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
