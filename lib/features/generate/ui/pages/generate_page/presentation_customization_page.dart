import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/service/generation_preferences_service.dart';
import 'package:datn_mobile/features/generate/ui/widgets/presentation_customization_widgets.dart';
import 'package:datn_mobile/features/generate/ui/widgets/theme_selection_section.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class PresentationCustomizationPage extends ConsumerStatefulWidget {
  const PresentationCustomizationPage({super.key});

  @override
  ConsumerState<PresentationCustomizationPage> createState() =>
      _PresentationCustomizationPageState();
}

class _PresentationCustomizationPageState
    extends ConsumerState<PresentationCustomizationPage> {
  final TextEditingController _avoidContentController = TextEditingController();
  late final t = ref.watch(translationsPod);

  @override
  void initState() {
    super.initState();
    final formState = ref.read(presentationFormControllerProvider);
    _avoidContentController.text = formState.avoidContent;

    // Pre-fetch defaults if not set
    _initializeDefaults();
  }

  Future<void> _initializeDefaults() async {
    final formState = ref.read(presentationFormControllerProvider);
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );
    final prefsService = ref.read(generationPreferencesServiceProvider);

    // 1. Initialize Image Model
    if (formState.imageModel == null) {
      final modelsState = await ref.read(
        modelsControllerPod(ModelType.image).future,
      );
      final savedModelId = prefsService.getPresentationImageModelId();

      AIModel? selectedModel;

      // Try saved preference
      if (savedModelId != null) {
        selectedModel = modelsState.availableModels
            .where((m) => m.id == savedModelId && m.isEnabled)
            .firstOrNull;
      }

      // Fallback to default
      selectedModel ??= modelsState.availableModels
          .where((m) => m.isDefault && m.isEnabled)
          .firstOrNull;

      if (selectedModel != null && mounted) {
        formController.updateImageModel(selectedModel);
      }
    }

    // 2. Initialize Theme
    if (formState.themeId == null) {
      final savedThemeId = prefsService.getPresentationThemeId();
      if (savedThemeId != null && mounted) {
        formController.updateThemeId(savedThemeId);
      }
    }
  }

  @override
  void dispose() {
    _avoidContentController.dispose();
    super.dispose();
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.generate.presentationCustomization.helpTitle),
        content: Text(t.generate.presentationCustomization.helpContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.generate.presentationCustomization.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final t = ref.watch(translationsPod);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final formState = ref.watch(presentationFormControllerProvider);
    final generateStateAsync = ref.watch(
      presentationGenerateControllerProvider,
    );

    // // Listen for generation completion (both outline regeneration and presentation)
    // ref.listen(presentationGenerateControllerProvider, (previous, next) {
    //   next.when(
    //     data: (state) {
    //       final wasLoading =
    //           previous?.maybeWhen(loading: () => true, orElse: () => false) ??
    //           false;

    //       // Only process if transitioning from loading to data state
    //       if (!wasLoading) return;

    //       // Handle outline regeneration - check if outline response just came in
    //       final previousState = previous?.maybeWhen(
    //         data: (s) => s,
    //         orElse: () => null,
    //       );

    //       if (state.outlineResponse != null &&
    //           (previousState?.outlineResponse == null)) {
    //         // Update the form state with new outline
    //         ref
    //             .read(presentationFormControllerProvider.notifier)
    //             .setOutline(state.outlineResponse!);
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text(
    //               t
    //                   .generate
    //                   .presentationCustomization
    //                   .outlineRegeneratedSuccess,
    //             ),
    //             backgroundColor: Colors.green,
    //             duration: const Duration(seconds: 2),
    //           ),
    //         );
    //       }

    //       // Handle presentation generation
    //       if (state.presentationResponse != null &&
    //           (previousState?.presentationResponse == null)) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text(
    //               t
    //                   .generate
    //                   .presentationCustomization
    //                   .presentationSubmittedSuccess,
    //             ),
    //             backgroundColor: Colors.green,
    //             duration: const Duration(seconds: 3),
    //           ),
    //         );
    //         // Navigate to home or presentation detail page
    //         context.router.popUntilRoot();
    //       }
    //     },
    //     loading: () {},
    //     error: (error, stackTrace) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text(
    //             t.generate.presentationCustomization.error(
    //               error: error.toString(),
    //             ),
    //           ),
    //           backgroundColor: Colors.red,
    //           duration: const Duration(seconds: 5),
    //         ),
    //       );
    //     },
    //   );
    // });

    return Scaffold(
      backgroundColor: isDark ? cs.surface : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Generation Options Section (from Step 1)
                    GenerationOptionsSection(
                      generateStateAsync: generateStateAsync,
                      onRegenerate: _handleRegenerate,
                    ),
                    const SizedBox(height: 24),

                    // Outline Summary Section
                    OutlineSummarySection(
                      outline: formState.outline,
                      onEdit: () => _navigateToEditor(context),
                    ),
                    const SizedBox(height: 24),

                    // Theme Selection
                    const ThemeSelectionSection(),
                    const SizedBox(height: 24),

                    // Image Model Selection
                    const ImageModelSection(),
                    const SizedBox(height: 24),

                    // Avoid Content Section
                    AvoidContentSection(
                      avoidContentController: _avoidContentController,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
            PresentationCustomizationActionBar(
              generateStateAsync: generateStateAsync,
              onEditOutline: () => _navigateToEditor(context),
              onGenerate: _handleGenerate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final t = ref.watch(translationsPod);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _handleBack(),
            icon: const Icon(LucideIcons.arrowLeft, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          // Generator type dropdown
          Expanded(
            child: Text(
              t.generate.presentationCustomization.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showHelpDialog(context),
            icon: Icon(
              LucideIcons.badgeQuestionMark,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Warn users that outlines will be lost
  void _handleBack() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.generate.presentationCustomization.discardChanges),
        content: Text(
          t.generate.presentationCustomization.discardChangesMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.generate.presentationCustomization.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.router.maybePop(); // Navigate back
            },
            child: Text(t.generate.presentationCustomization.discard),
          ),
        ],
      ),
    );
  }

  void _handleRegenerate() {
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );
    final request = formController.toOutlineData();
    ref
        .read(presentationGenerateControllerProvider.notifier)
        .generateOutline(request);
  }

  void _navigateToEditor(BuildContext context) {
    final formState = ref.read(presentationFormControllerProvider);
    final editingController = ref.read(
      outlineEditingControllerProvider.notifier,
    );
    editingController.initializeFromOutline(formState.outline);
    context.router.push(const OutlineEditorRoute());
  }

  void _handleGenerate() {
    try {
      final formController = ref.read(
        presentationFormControllerProvider.notifier,
      );
      // Validates request before navigating
      formController.toPresentationRequest();

      context.router.push(const PresentationGenerationWebViewRoute());
    } catch (e) {
      String message = e.toString();
      if (e is FormatException) {
        message = e.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
