import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/generation_settings_sheet.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/image_suggestions.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/topic_input_bar.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/image_picker_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/image_widget_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/attach_file_sheet.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ImageGeneratePage extends ConsumerStatefulWidget {
  const ImageGeneratePage({super.key});

  @override
  ConsumerState<ImageGeneratePage> createState() => _ImageGeneratePageState();
}

class _ImageGeneratePageState extends ConsumerState<ImageGeneratePage> {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  late final t = ref.watch(translationsPod);

  @override
  void initState() {
    super.initState();
    // Initialize controller with current prompt from state
    final formState = ref.read(imageFormControllerProvider);
    _promptController.text = formState.prompt;

    // Listen for text changes and update state
    _promptController.addListener(_onPromptChanged);

    // Pre-fetch models and set default if not already set
    _initializeDefaultModel();
  }

  Future<void> _initializeDefaultModel() async {
    final formState = ref.read(imageFormControllerProvider);
    if (formState.selectedModel == null) {
      // Fetch image models and get default
      final modelsState = await ref.read(
        modelsControllerPod(ModelType.image).future,
      );
      final defaultModel = modelsState.availableModels
          .where((m) => m.isDefault && m.isEnabled)
          .firstOrNull;
      if (defaultModel != null && mounted) {
        ref
            .read(imageFormControllerProvider.notifier)
            .updateModel(defaultModel);
      }
    }
  }

  @override
  void dispose() {
    _promptController.removeListener(_onPromptChanged);
    _promptController.dispose();
    _promptFocusNode.dispose();
    super.dispose();
  }

  void _onPromptChanged() {
    ref
        .read(imageFormControllerProvider.notifier)
        .updatePrompt(_promptController.text);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Listen for generation completion
    ref.listen(imageGenerateControllerProvider, (previous, next) {
      next.when(
        data: (state) {
          // Check if a new image was generated
          final hadImage =
              previous?.maybeWhen(
                data: (prevState) => prevState.generatedImage != null,
                orElse: () => false,
              ) ??
              false;
          final hasNewImage = !hadImage && state.generatedImage != null;

          if (hasNewImage) {
            // Navigate to result page
            context.router.push(const ImageResultRoute());
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          if (context.mounted) {
            SnackbarUtils.showError(
              context,
              'Error generating image: ${error.toString()}',
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
              topicController: _promptController,
              topicFocusNode: _promptFocusNode,
              generateState: imageGenerateControllerProvider,
              formState: imageFormControllerProvider,
              onAttachFile: () => AttachFileSheet.show(context: context, t: t),
              onGenerate: _handleGenerate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
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
              Icons.image_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            t.generate.imageGenerate.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            t.generate.imageGenerate.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.secondaryTextColor),
          ),
          const SizedBox(height: 32),
          // Options Row
          Consumer(
            builder: (context, ref, _) {
              final formState = ref.watch(imageFormControllerProvider);
              final formController = ref.watch(
                imageFormControllerProvider.notifier,
              );

              return Column(
                children: [
                  GeneralPickerOptions.buildOptionsRow(
                    context,
                    formState,
                    formController,
                    [
                      OptionChip(
                        icon: LucideIcons.ratio,
                        label: formState.aspectRatio,
                        onTap: () => ImagePickerOptions.showRatioImage(
                          context,
                          ref.read(imageFormControllerProvider.notifier),
                          formState,
                          t,
                        ),
                      ),
                      OptionChip(
                        icon: Icons.psychology,
                        label:
                            formState.selectedModel?.displayName ??
                            t.generate.presentationGenerate.selectModel,
                        onTap: () => GeneralPickerOptions.showModelPicker(
                          context,
                          selectedModel: formState.selectedModel,
                          modelType: ModelType.image,
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
                          ImageWidgetOptions().buildAllSettings(t),
                        );
                      },
                      child: const Text("Advanced Settings"),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          // Image Suggestions
          ImageSuggestions(
            onSuggestionTap: (suggestion) {
              _promptController.text = suggestion;
              ref
                  .read(imageFormControllerProvider.notifier)
                  .updatePrompt(suggestion);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _handleGenerate() {
    _promptFocusNode.unfocus();
    ref.read(imageGenerateControllerProvider.notifier).generateImage();
  }
}
