import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/generation_settings_sheet.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/presentation_picker_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/presentation_widget_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/attach_file_sheet.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/topic_input_bar.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/topic_suggestions.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class PresentationGeneratePage extends ConsumerStatefulWidget {
  const PresentationGeneratePage({super.key});

  @override
  ConsumerState<PresentationGeneratePage> createState() =>
      _PresentationGeneratePageState();
}

class _PresentationGeneratePageState
    extends ConsumerState<PresentationGeneratePage> {
  final TextEditingController _topicController = TextEditingController();
  final FocusNode _topicFocusNode = FocusNode();
  late final t = ref.watch(translationsPod);

  @override
  void initState() {
    super.initState();
    // Initialize controller with current topic from state
    final formState = ref.read(presentationFormControllerProvider);
    _topicController.text = formState.topic;

    // Listen for text changes and update state
    _topicController.addListener(_onTopicChanged);

    // Pre-fetch models and set default if not already set
    _initializeDefaultModel();
  }

  Future<void> _initializeDefaultModel() async {
    final formState = ref.read(presentationFormControllerProvider);
    if (formState.outlineModel == null) {
      // Fetch text models and get default
      final modelsState = await ref.read(
        modelsControllerPod(ModelType.text).future,
      );
      final defaultModel = modelsState.availableModels
          .where((m) => m.isDefault && m.isEnabled)
          .firstOrNull;
      if (defaultModel != null && mounted) {
        ref
            .read(presentationFormControllerProvider.notifier)
            .updateOutlineModel(defaultModel);
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
        .read(presentationFormControllerProvider.notifier)
        .updateTopic(_topicController.text);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Listen for generation completion
    ref.listen(presentationGenerateControllerProvider, (previous, next) {
      next.when(
        data: (state) {
          // Check if a new outline was generated
          final hadOutline =
              previous?.maybeWhen(
                data: (prevState) => prevState.outlineResponse != null,
                orElse: () => false,
              ) ??
              false;
          final hasNewOutline = !hadOutline && state.outlineResponse != null;

          if (hasNewOutline) {
            // Save outline to form state
            ref
                .read(presentationFormControllerProvider.notifier)
                .setOutline(state.outlineResponse!);
            // Navigate to customization page
            if (context.router.current.name == PresentationGenerateRoute.name) {
              context.router.push(const PresentationCustomizationRoute());
            } else {
              context.router.replace(const PresentationCustomizationRoute());
            }
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          if (context.mounted) {
            SnackbarUtils.showError(
              context,
              t.generate.presentationCustomization.error(
                error: error.toString(),
              ),
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
              generateState: presentationGenerateControllerProvider,
              formState: presentationFormControllerProvider,
              onAttachFile: () => AttachFileSheet.show(context: context, t: t),
              onGenerate: _handleGenerate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final formState = ref.watch(presentationFormControllerProvider);
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );
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
              Icons.auto_awesome,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            t.generate.presentationGenerate.title,
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
          // Options Row
          Column(
            children: [
              GeneralPickerOptions.buildOptionsRow(
                context,
                formState,
                formController,
                [
                  OptionChip(
                    icon: Icons.format_list_numbered,
                    label: t.generate.presentationGenerate.slidesCount(
                      count: formState.slideCount,
                    ),
                    onTap: () => PresentationPickerOptions.showSlideCountPicker(
                      formController,
                      formState,
                      context,
                      t,
                    ),
                  ),
                  // Language
                  OptionChip(
                    icon: Icons.language,
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
                    icon: Icons.psychology,
                    label:
                        formState.outlineModel?.displayName ??
                        t.generate.presentationGenerate.selectModel,
                    onTap: () => GeneralPickerOptions.showModelPicker(
                      context,
                      selectedModel: formState.outlineModel,
                      modelType: ModelType.text,
                      onSelected: formController.updateOutlineModel,
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
                      PresentationWidgetOptions().buildAllSettings(t),
                    );
                  },
                  child: const Text("Advanced Settings"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick Suggestions
          TopicSuggestions(
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
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );
    final outlineData = formController.toOutlineData();
    ref
        .read(presentationGenerateControllerProvider.notifier)
        .generateOutline(outlineData);
  }
}
