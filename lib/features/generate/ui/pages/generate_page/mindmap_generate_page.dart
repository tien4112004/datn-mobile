import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/generation_settings_sheet.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/topic_input_bar.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/mindmap_picker_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/mindmap_widget_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/attach_file_sheet.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/utils/snackbar_utils.dart';
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

    // Listen for generation completion
    ref.listen(mindmapGenerateControllerProvider, (previous, next) {
      next.when(
        data: (state) {
          // Check if a new mindmap was generated
          final hadMindmap =
              previous?.maybeWhen(
                data: (prevState) => prevState.generatedMindmap != null,
                orElse: () => false,
              ) ??
              false;
          final hasNewMindmap = !hadMindmap && state.generatedMindmap != null;

          if (hasNewMindmap) {
            // Navigate to result page
            context.router.push(const MindmapResultRoute());
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          if (context.mounted) {
            SnackbarUtils.showError(
              context,
              t.generate.mindmapGenerate.error(error: error.toString()),
            );
          }
        },
      );
    });

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
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
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
        ],
      ),
    );
  }

  void _handleGenerate() {
    _topicFocusNode.unfocus();
    ref.read(mindmapGenerateControllerProvider.notifier).generateMindmap();
  }
}
