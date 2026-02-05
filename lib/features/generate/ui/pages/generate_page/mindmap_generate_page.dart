import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/generation_settings_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/topic_input_bar.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/mindmap_picker_options.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/mindmap_widget_options.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/attach_file_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/suggestions/example_prompt_suggestions.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/provider_logo_utils.dart';
import 'package:AIPrimary/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class MindmapGeneratePage extends ConsumerStatefulWidget {
  const MindmapGeneratePage({super.key});

  @override
  ConsumerState<MindmapGeneratePage> createState() =>
      _MindmapGeneratePageState();
}

class _MindmapGeneratePageState extends ConsumerState<MindmapGeneratePage> {
  final TextEditingController _topicController = TextEditingController();
  final FocusNode _topicFocusNode = FocusNode();
  late final t = ref.watch(translationsPod);

  @override
  void initState() {
    super.initState();
    // Initialize controller with current topic from state
    final formState = ref.read(mindmapFormControllerProvider);
    _topicController.text = formState.topic;

    // Listen for text changes and update state
    _topicController.addListener(_onTopicChanged);

    // Pre-fetch models and set default if not already set
    _initializeDefaultModel();
  }

  Future<void> _initializeDefaultModel() async {
    final formState = ref.read(mindmapFormControllerProvider);
    if (formState.selectedModel == null) {
      // Fetch text models and get default
      final modelsState = await ref.read(
        modelsControllerPod(ModelType.text).future,
      );
      final defaultModel = modelsState.availableModels
          .where((m) => m.isDefault && m.isEnabled)
          .firstOrNull;
      if (defaultModel != null && mounted) {
        ref
            .read(mindmapFormControllerProvider.notifier)
            .updateModel(defaultModel);
      }
    }
  }

  @override
  void dispose() {
    _topicController.removeListener(_onTopicChanged);
    _topicController.dispose();
    _topicFocusNode.dispose();
    super.dispose();
  }

  void _onTopicChanged() {
    ref
        .read(mindmapFormControllerProvider.notifier)
        .updateTopic(_topicController.text);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Note: Generation is now handled by WebView page, no listener needed here

    return Scaffold(
      backgroundColor: context.isDarkMode
          ? cs.surface
          : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(child: _buildMainContent(context)),
            // Bottom Input Section
            TopicInputBar(
              topicController: _topicController,
              topicFocusNode: _topicFocusNode,
              generateState: mindmapGenerateControllerProvider,
              formState: mindmapFormControllerProvider,
              onAttachFile: () => AttachFileSheet.show(context: context, t: t),
              onGenerate: _handleGenerate,
              hintText: t.generate.enterTopicHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final formState = ref.watch(mindmapFormControllerProvider);
    final formController = ref.watch(mindmapFormControllerProvider.notifier);

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
                  ResourceType.mindmap.color.withValues(alpha: 0.8),
                  ResourceType.mindmap.color.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              LucideIcons.brainCircuit400,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            t.generate.mindmapGenerate.pageTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            t.generate.mindmapGenerate.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.secondaryTextColor),
          ),
          const SizedBox(height: 40),
          // Options
          Column(
            children: [
              GeneralPickerOptions.buildOptionsRow(
                context,
                formState,
                formController,
                [
                  OptionChip(
                    icon: LucideIcons.layers,
                    label: t.generate.mindmapGenerate.maxDepth(
                      depth: formState.maxDepth,
                    ),
                    onTap: () => MindmapPickerOptions.showMaxDepthPicker(
                      context,
                      formState,
                      formController,
                      t,
                    ),
                  ),
                  OptionChip(
                    icon: LucideIcons.layers,
                    label: t.generate.mindmapGenerate.maxBranches(
                      branches: formState.maxBranchesPerNode,
                    ),
                    onTap: () => MindmapPickerOptions.showMaxBranchesPicker(
                      context,
                      formState,
                      formController,
                      t,
                    ),
                  ),

                  // Language
                  OptionChip(
                    icon: LucideIcons.languages,
                    label: formState.language.isEmpty
                        ? t.locale_en
                        : formState.language,
                    onTap: () => GeneralPickerOptions.showLanguagePicker(
                      context,
                      formController,
                      formState,
                      t,
                    ),
                  ),
                  // Model
                  OptionChip(
                    icon: LucideIcons.bot,
                    label:
                        formState.selectedModel?.displayName ??
                        t.generate.mindmapGenerate.selectModel,
                    logoPath: formState.selectedModel != null
                        ? ProviderLogoUtils.getLogoPath(
                            formState.selectedModel!.provider,
                          )
                        : null,
                    onTap: () => GeneralPickerOptions.showModelPicker(
                      context,
                      selectedModel: formState.selectedModel,
                      modelType: ModelType.text,
                      onSelected: formController.updateModel,
                      t: t,
                    ),
                  ),
                ],
                t,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    GenerationSettingsSheet.show(
                      context,
                      MindmapWidgetOptions().buildAllSettings(t),
                      ModelType.text,
                      t.generate.generationSettings.title,
                      t.generate.generationSettings.done,
                    );
                  },
                  child: Text(t.generate.advancedSettings),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick Suggestions
          ExamplePromptSuggestions(
            type: 'MINDMAP',
            headerText: t.generate.mindmapGenerate.tryTheseTopics,
            onSuggestionTap: (suggestion) {
              _topicController.text = suggestion;
            },
          ),
        ],
      ),
    );
  }

  void _handleGenerate() {
    _topicFocusNode.unfocus();
    // Validate form before navigating
    final formState = ref.read(mindmapFormControllerProvider);
    if (!formState.isValid) {
      // Form requires topic and model to be set
      if (formState.topic.trim().isEmpty) {
        SnackbarUtils.showError(context, t.generate.enterTopicHint);
      } else if (formState.selectedModel == null) {
        SnackbarUtils.showError(
          context,
          t.generate.mindmapGenerate.selectModel,
        );
      }
      return;
    }
    // Navigate to WebView generation page
    context.router.push(const MindmapGenerationWebViewRoute());
  }
}
