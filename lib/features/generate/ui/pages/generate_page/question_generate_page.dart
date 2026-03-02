import 'package:AIPrimary/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/generation_settings_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/states/questions/question_generate_form_state.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/topic_input_bar.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_widget_options.dart';
import 'package:AIPrimary/shared/utils/provider_logo_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/ui/widgets/suggestions/example_prompt_suggestions.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
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

  @override
  void initState() {
    super.initState();
    final formState = ref.read(questionGenerateFormControllerProvider);
    _topicController.text = formState.topic;
    _topicController.addListener(_onTopicChanged);
  }

  void _onTopicChanged() {
    ref
        .read(questionGenerateFormControllerProvider.notifier)
        .updateTopic(_topicController.text);
  }

  @override
  void dispose() {
    _topicController.removeListener(_onTopicChanged);
    _topicController.dispose();
    _topicFocusNode.dispose();
    super.dispose();
  }

  QuestionGenerateFormController get _formController =>
      ref.read(questionGenerateFormControllerProvider.notifier);

  Future<void> _handleGenerate() async {
    _topicFocusNode.unfocus();
    final formState = ref.read(questionGenerateFormControllerProvider);
    if (!formState.isValid) return;

    final entity = _formController.toRequestEntity();

    await ref
        .read(questionGenerationProvider.notifier)
        .generateQuestions(entity);

    final state = ref.read(questionGenerationProvider);
    if (mounted && state.generatedQuestions.isNotEmpty) {
      context.router.push(const QuestionGenerateResultRoute());
    }
  }

  void _showAdvancedSettings(QuestionGenerateFormState formState) {
    // Local mutable copies so StatefulBuilder inside QuestionWidgetOptions
    // can see mutations immediately (it closes over these references).
    // Changes are also pushed to the provider so the parent page stays in sync.
    final localTypes = Set<QuestionType>.from(formState.selectedTypes);
    final localCounts = Map<Difficulty, int>.from(formState.difficultyCounts);

    final promptController = TextEditingController(text: formState.prompt);
    promptController.addListener(
      () => _formController.updatePrompt(promptController.text),
    );

    GenerationSettingsSheet.show(
      context: context,
      optionWidgets: QuestionWidgetOptions(
        grade: formState.grade,
        subject: formState.subject,
        selectedTypes: localTypes,
        difficultyCounts: localCounts,
        promptController: promptController,
        selectedChapter: formState.chapter,
        onGradeChanged: (g) => _formController.updateGrade(g),
        onSubjectChanged: (s) => _formController.updateSubject(s),
        onTypesChanged: (types) {
          localTypes
            ..clear()
            ..addAll(types);
          _formController.updateSelectedTypes(types);
        },
        onDifficultyChanged: (counts) {
          localCounts
            ..clear()
            ..addAll(counts);
          _formController.updateDifficultyCounts(counts);
        },
        onChapterChanged: (c) => _formController.updateChapter(c),
      ).buildAllSettings(t),
      modelType: ModelType.text,
      title: t.generate.generationSettings.title,
      buttonText: t.generate.generationSettings.done,
      selectedModel: formState.selectedModel,
      onModelChanged: (model) => _formController.updateModel(model),
    );
  }

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(questionGenerationProvider);
    final formState = ref.watch(questionGenerateFormControllerProvider);

    // Keep topic controller in sync with provider state
    if (_topicController.text != formState.topic) {
      _topicController.text = formState.topic;
    }

    return Scaffold(
      backgroundColor: Themes.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMainContent(context, genState, formState)),
            TopicInputBar(
              topicController: _topicController,
              topicFocusNode: _topicFocusNode,
              formState: questionGenerateFormControllerProvider,
              generateState: questionGenerateAsyncProvider,
              onGenerate: _handleGenerate,
              hintText: genState.generatedQuestions.isNotEmpty
                  ? t.generate.questionGenerate.generateMoreHint
                  : t.generate.enterTopicHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    QuestionGenerationState genState,
    QuestionGenerateFormState formState,
  ) {
    final hasResults = genState.generatedQuestions.isNotEmpty;
    final activeDifficultyCount = formState.totalQuestionCount;
    final typeLabel = formState.selectedTypes.isEmpty
        ? t.questionBank.filters.type
        : formState.selectedTypes.length == 1
        ? formState.selectedTypes.first.displayName
        : '${formState.selectedTypes.length} ${t.questionBank.filters.type.toLowerCase()}';

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
                  label: formState.grade.getLocalizedName(t),
                  onTap: () => GeneralPickerOptions.showEnumPicker<GradeLevel>(
                    context: context,
                    title: t.generate.presentationGenerate.grade,
                    values: GradeLevel.values,
                    labelOf: (g) => g.getLocalizedName(t),
                    isSelected: (g) => g == formState.grade,
                    onSelected: (g) => _formController.updateGrade(g),
                  ),
                ),
                OptionChip(
                  icon: LucideIcons.bookOpen,
                  label: formState.subject.getLocalizedName(t),
                  onTap: () => GeneralPickerOptions.showEnumPicker<Subject>(
                    context: context,
                    title: t.generate.presentationGenerate.subject,
                    values: Subject.values,
                    labelOf: (s) => s.getLocalizedName(t),
                    isSelected: (s) => s == formState.subject,
                    onSelected: (s) => _formController.updateSubject(s),
                  ),
                ),
                OptionChip(
                  icon: LucideIcons.listChecks,
                  label: QuestionType.getLocalizedNameFromDisplayName(
                    t,
                    typeLabel,
                  ),
                  onTap: () => _showAdvancedSettings(formState),
                ),
                OptionChip(
                  icon: LucideIcons.layers,
                  label: activeDifficultyCount == 0
                      ? t.common.difficulty
                      : '$activeDifficultyCount q.',
                  onTap: () => _showAdvancedSettings(formState),
                ),
                OptionChip(
                  icon: LucideIcons.bot,
                  label:
                      formState.selectedModel?.displayName ??
                      t.generate.presentationGenerate.selectModel,
                  logoPath: formState.selectedModel != null
                      ? ProviderLogoUtils.getLogoPath(
                          formState.selectedModel!.provider,
                        )
                      : null,
                  onTap: () => GeneralPickerOptions.showModelPicker(
                    context,
                    selectedModel: formState.selectedModel,
                    modelType: ModelType.text,
                    onSelected: (m) => _formController.updateModel(m),
                    t: t,
                  ),
                ),
              ], t),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showAdvancedSettings(formState),
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
                _formController.updateTopic(suggestion);
              },
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}
