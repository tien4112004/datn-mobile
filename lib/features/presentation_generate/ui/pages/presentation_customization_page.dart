import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/generate/controllers/pods/models_controller_pod.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/presentation_generate/states/controller_provider.dart';
import 'package:datn_mobile/features/presentation_generate/ui/widgets/presentation_customization_widgets.dart';
import 'package:datn_mobile/features/presentation_generate/ui/widgets/theme_selection_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    final formState = ref.read(presentationFormControllerProvider);
    _avoidContentController.text = formState.avoidContent;

    // Pre-fetch image models and set default if not already set
    _initializeDefaultImageModel();
  }

  Future<void> _initializeDefaultImageModel() async {
    final formState = ref.read(presentationFormControllerProvider);
    if (formState.imageModel == null) {
      // Fetch image models and get default
      final modelsState = await ref.read(
        modelsControllerPod(ModelType.image).future,
      );
      final defaultModel = modelsState.availableModels
          .where((m) => m.isDefault && m.isEnabled)
          .firstOrNull;
      if (defaultModel != null && mounted) {
        ref
            .read(presentationFormControllerProvider.notifier)
            .updateImageModel(defaultModel);
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
        title: const Text('Customize Presentation'),
        content: const Text(
          '• Select a theme for your presentation\n'
          '• Choose an image generation model\n'
          '• Optionally specify content to avoid\n'
          '• Tap "Edit Outline" to modify your slides\n'
          '• Tap "Generate" to create your presentation',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final formState = ref.watch(presentationFormControllerProvider);
    final generateState = ref.watch(presentationGenerateControllerProvider);

    final isLoading = generateState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    // Listen for generation completion (both outline regeneration and presentation)
    ref.listen(presentationGenerateControllerProvider, (previous, next) {
      next.when(
        data: (state) {
          final wasLoading =
              previous?.maybeWhen(loading: () => true, orElse: () => false) ??
              false;

          // Only process if transitioning from loading to data state
          if (!wasLoading) return;

          // Handle outline regeneration - check if outline response just came in
          final previousState = previous?.maybeWhen(
            data: (s) => s,
            orElse: () => null,
          );

          if (state.outlineResponse != null &&
              (previousState?.outlineResponse == null)) {
            // Update the form state with new outline
            ref
                .read(presentationFormControllerProvider.notifier)
                .setOutline(state.outlineResponse!.outline);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Outline regenerated successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }

          // Handle presentation generation
          if (state.presentationResponse != null &&
              (previousState?.presentationResponse == null)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Presentation submitted! Your presentation is being created',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            // Navigate to home or presentation detail page
            context.router.popUntilRoot();
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        },
      );
    });

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
                      isLoading: isLoading,
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
              isLoading: isLoading,
              onEditOutline: () => _navigateToEditor(context),
              onGenerate: _handleGenerate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          // Generator type dropdown
          Expanded(
            child: Text(
              'Customize Presentation',
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
              Icons.question_mark_outlined,
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
        title: const Text('Discard Changes?'),
        content: const Text(
          'Going back will discard any unsaved changes to your outline. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.router.maybePop(); // Navigate back
            },
            child: const Text('Discard'),
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
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );
    final request = formController.toPresentationRequest();
    ref
        .read(presentationGenerateControllerProvider.notifier)
        .generatePresentation(request);
  }
}
