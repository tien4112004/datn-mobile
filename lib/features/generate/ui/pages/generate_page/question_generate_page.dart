import 'package:AIPrimary/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/generation_settings_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_widget_options.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/ui/widgets/suggestions/example_prompt_suggestions.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/questions/domain/entity/generate_questions_request_entity.dart';
import 'package:AIPrimary/features/questions/states/question_generation_provider.dart';
import 'package:AIPrimary/features/questions/states/question_generation_state.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class QuestionGeneratePage extends ConsumerStatefulWidget {
  const QuestionGeneratePage({super.key});

  @override
  ConsumerState<QuestionGeneratePage> createState() =>
      _QuestionGeneratePageState();
}

class _QuestionGeneratePageState extends ConsumerState<QuestionGeneratePage> {
  final TextEditingController _topicController = TextEditingController();
  final FocusNode _topicFocusNode = FocusNode();
  late final t = ref.watch(translationsPod);

  GradeLevel? _grade;
  Subject? _subject;
  String? _selectedChapter;
  final Set<QuestionType> _selectedTypes = {QuestionType.multipleChoice};
  final Map<Difficulty, int> _difficultyCounts = {
    for (final d in Difficulty.values) d: 0,
  };
  AIModel? _selectedModel;
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    _topicFocusNode.dispose();
    _promptController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _topicController.text.trim().isNotEmpty &&
      _grade != null &&
      _subject != null &&
      _selectedTypes.isNotEmpty &&
      _difficultyCounts.values.any((c) => c > 0);

  Future<void> _handleGenerate() async {
    _topicFocusNode.unfocus();
    if (!_isValid) return;

    final activeCounts = Map.fromEntries(
      _difficultyCounts.entries.where((e) => e.value > 0),
    );

    final entity = GenerateQuestionsRequestEntity(
      topic: _topicController.text.trim(),
      grade: _grade!,
      subject: _subject!,
      questionsPerDifficulty: activeCounts,
      questionTypes: _selectedTypes.toList(),
      provider: _selectedModel?.provider,
      model: _selectedModel?.id.toString(),
      prompt: _promptController.text.trim().isEmpty
          ? null
          : _promptController.text.trim(),
      chapter: _selectedChapter,
    );

    await ref
        .read(questionGenerationProvider.notifier)
        .generateQuestions(entity);

    final state = ref.read(questionGenerationProvider);
    if (mounted && state.generatedQuestions.isNotEmpty) {
      context.router.push(const QuestionGenerateResultRoute());
    }
  }

  void _showAdvancedSettings() {
    GenerationSettingsSheet.show(
      context: context,
      optionWidgets: QuestionWidgetOptions(
        grade: _grade ?? GradeLevel.grade1,
        subject: _subject ?? Subject.mathematics,
        selectedTypes: _selectedTypes,
        difficultyCounts: _difficultyCounts,
        promptController: _promptController,
        selectedChapter: _selectedChapter,
        onGradeChanged: (g) => setState(() {
          _grade = g;
          _selectedChapter = null;
        }),
        onSubjectChanged: (s) => setState(() {
          _subject = s;
          _selectedChapter = null;
        }),
        onTypesChanged: (types) => setState(() {
          _selectedTypes
            ..clear()
            ..addAll(types);
        }),
        onDifficultyChanged: (counts) => setState(() {
          _difficultyCounts
            ..clear()
            ..addAll(counts);
        }),
        onChapterChanged: (c) => setState(() => _selectedChapter = c),
      ).buildAllSettings(t),
      modelType: ModelType.text,
      title: t.generate.generationSettings.title,
      buttonText: t.generate.generationSettings.done,
      selectedModel: _selectedModel,
      onModelChanged: (model) => setState(() => _selectedModel = model),
    );
  }

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(questionGenerationProvider);
    return Scaffold(
      backgroundColor: Themes.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMainContent(context, genState)),
            _buildBottomBar(context, genState),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    QuestionGenerationState genState,
  ) {
    final hasResults = genState.generatedQuestions.isNotEmpty;
    final activeDifficultyCount = _difficultyCounts.values.fold(
      0,
      (a, b) => a + b,
    );
    final typeLabel = _selectedTypes.isEmpty
        ? t.questionBank.filters.type
        : _selectedTypes.length == 1
        ? _selectedTypes.first.displayName
        : '${_selectedTypes.length} ${t.questionBank.filters.type.toLowerCase()}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ResourceType.question.color.withValues(alpha: 0.8),
                  ResourceType.question.color.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              ResourceType.question.icon,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            t.generate.generatorTypes.question,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            t.generate.presentationGenerate.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.secondaryTextColor),
          ),

          const SizedBox(height: 40),

          // Option chips + Advanced Settings button
          Column(
            children: [
              GeneralPickerOptions.buildOptionsRow(context, null, null, [
                OptionChip(
                  icon: LucideIcons.graduationCap,
                  label:
                      _grade?.getLocalizedName(t) ??
                      t.generate.presentationGenerate.grade,
                  onTap: () => GeneralPickerOptions.showEnumPicker<GradeLevel>(
                    context: context,
                    title: t.generate.presentationGenerate.grade,
                    values: GradeLevel.values,
                    labelOf: (g) => g.getLocalizedName(t),
                    isSelected: (g) => g == _grade,
                    onSelected: (g) => setState(() {
                      _grade = g;
                      _selectedChapter = null;
                    }),
                  ),
                ),
                OptionChip(
                  icon: LucideIcons.bookOpen,
                  label:
                      _subject?.getLocalizedName(t) ??
                      t.generate.presentationGenerate.subject,
                  onTap: () => GeneralPickerOptions.showEnumPicker<Subject>(
                    context: context,
                    title: t.generate.presentationGenerate.subject,
                    values: Subject.values,
                    labelOf: (s) => s.getLocalizedName(t),
                    isSelected: (s) => s == _subject,
                    onSelected: (s) => setState(() {
                      _subject = s;
                      _selectedChapter = null;
                    }),
                  ),
                ),
                OptionChip(
                  icon: LucideIcons.listChecks,
                  label: typeLabel,
                  onTap: _showAdvancedSettings,
                ),
                OptionChip(
                  icon: LucideIcons.layers,
                  label: activeDifficultyCount == 0
                      ? t.common.difficulty
                      : '$activeDifficultyCount q.',
                  onTap: _showAdvancedSettings,
                ),
              ], t),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showAdvancedSettings,
                  child: Text(t.generate.advancedSettings),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Error banner
          if (genState.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      genState.error!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Example prompts
          if (!hasResults) ...[
            ExamplePromptSuggestions(
              type: 'QUESTION',
              headerText: t.generate.presentationGenerate.tryTheseTopics,
              onSuggestionTap: (suggestion) {
                _topicController.text = suggestion;
                setState(() {});
              },
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  // ── Bottom input bar ────────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    QuestionGenerationState genState,
  ) {
    final hasResults = genState.generatedQuestions.isNotEmpty;
    final isLoading = genState.isLoading;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Topic input
            Expanded(child: _buildTextInput(context, hasResults)),
            const SizedBox(width: 8),

            // Generate button
            _buildIconButton(
              color: _isValid && !isLoading
                  ? cs.primary
                  : _disabledColor(context),
              onTap: _isValid && !isLoading ? _handleGenerate : null,
              isLoading: isLoading,
              icon: Icons.arrow_upward_rounded,
              iconColor: _isValid ? Colors.white : Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(BuildContext context, bool hasResults) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _topicController,
        focusNode: _topicFocusNode,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hasResults
              ? t.generate.questionGenerate.generateMoreHint
              : t.generate.enterTopicHint,
          hintStyle: TextStyle(
            color: context.isDarkMode ? Colors.grey[500] : Colors.grey[400],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: context.isDarkMode ? Colors.white : Colors.grey[900],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required Color? color,
    required VoidCallback? onTap,
    required bool isLoading,
    required IconData icon,
    Color? iconColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon, color: iconColor ?? Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Color? _disabledColor(BuildContext context) =>
      context.isDarkMode ? Colors.grey[700] : Colors.grey[300];
}
