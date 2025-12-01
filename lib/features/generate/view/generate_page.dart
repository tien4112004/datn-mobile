import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/generate/controllers/generation_controller_pod.dart';
import 'package:datn_mobile/features/generate/domain/entities/generation_config.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/generate/view/widgets/common/description_input_section.dart';
import 'package:datn_mobile/features/generate/view/widgets/common/generation_button.dart';
import 'package:datn_mobile/features/generate/view/widgets/presentation/presentation_options_section.dart';
import 'package:datn_mobile/features/generate/view/widgets/presentation/presentation_prompts.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/shared/widget/header_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Generic generate page that adapts based on resource type
/// Currently implements presentation generation, ready for image/mindmap
@RoutePage()
class GeneratePage extends ConsumerStatefulWidget {
  final ResourceType resourceType; // presentation, image, mindmap

  const GeneratePage({required this.resourceType, super.key});

  @override
  ConsumerState<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends ConsumerState<GeneratePage> {
  // Presentation-specific state
  late int _grade;
  late String _theme;
  late AIModel? _selectedModel;

  final TextEditingController _descriptionCtl = TextEditingController();
  final TextEditingController _slidesCtl = TextEditingController(text: '10');
  final TextEditingController _avoidCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _grade = 1;
    _theme = 'Lorems';
    _selectedModel = null;
  }

  @override
  void dispose() {
    _descriptionCtl.dispose();
    _slidesCtl.dispose();
    _avoidCtl.dispose();
    super.dispose();
  }

  void _handleGenerate() {
    if (_selectedModel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a model')));
      return;
    }

    final options = <String, dynamic>{
      'slideCount': int.tryParse(_slidesCtl.text),
      'grade': _grade,
      'theme': _theme,
      'avoidContent': _avoidCtl.text.isNotEmpty ? _avoidCtl.text : null,
    };

    final config = GenerationConfig(
      resourceType: widget.resourceType,
      model: _selectedModel!,
      description: _descriptionCtl.text,
      options: options,
    );

    ref.read(generationControllerPod.notifier).generate(config);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final generationState = ref.watch(generationControllerPod);

    final pageTitle = switch (widget.resourceType) {
      ResourceType.presentation => 'Presentation',
      ResourceType.image => 'Image',
      ResourceType.mindmap => 'Mindmap',
    };

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            HeaderBar(
              title: pageTitle,
              onBack: () => context.router.maybePop(),
              onHelp: () {
                // TODO: Implement help functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help coming soon')),
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resource-specific options
                    if (widget.resourceType == ResourceType.presentation) ...[
                      PresentationOptionsSection(
                        slidesController: _slidesCtl,
                        grade: _grade,
                        onGradeChanged: (value) {
                          setState(() => _grade = value);
                        },
                        theme: _theme,
                        onThemeChanged: (value) {
                          setState(() => _theme = value);
                        },
                        avoidController: _avoidCtl,
                        selectedModel: _selectedModel,
                        onModelChanged: (model) {
                          setState(() => _selectedModel = model);
                        },
                        onInfoTap: () {
                          // TODO: Show options help dialog
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    // TODO: Add image-specific options
                    // TODO: Add mindmap-specific options

                    // Description Input
                    DescriptionInputSection(
                      controller: _descriptionCtl,
                      suggestions:
                          widget.resourceType == ResourceType.presentation
                          ? PresentationPrompts.suggestions
                          : [],
                      label: 'Describe your ${widget.resourceType.value}',
                      hint: 'Enter your description...',
                    ),

                    // TODO: Implement attach resources functionality
                    // const SizedBox(height: 20),
                    // AttachBox(onAdd: () {}),

                    // Show result or error
                    generationState.when(
                      data: (state) {
                        if (state.result != null) {
                          return _buildResultSection(state.result!.content);
                        } else if (state.errorMessage != null) {
                          return _buildErrorSection(state.errorMessage!);
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (error, _) => _buildErrorSection(error.toString()),
                    ),
                  ],
                ),
              ),
            ),

            // Generate Button
            GenerationButton(
              onPressed: _handleGenerate,
              isLoading: generationState.isLoading,
              label: 'Generate',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(String content) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Generated Content',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(generationControllerPod.notifier).reset();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(child: SelectableText(content)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy to Clipboard'),
                onPressed: () {
                  // TODO: Implement copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copy coming soon')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generation Error',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
