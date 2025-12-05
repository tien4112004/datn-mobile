import 'package:datn_mobile/features/generate/controllers/pods/models_controller_pod.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/presentation_generate/service/outline_parser.dart';
import 'package:datn_mobile/features/presentation_generate/states/controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays generation settings like topic, slide count, language, and model
class GenerationOptionsSection extends ConsumerWidget {
  final bool isLoading;
  final VoidCallback onRegenerate;

  const GenerationOptionsSection({
    super.key,
    required this.isLoading,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formState = ref.watch(presentationFormControllerProvider);
    final textModelsAsync = ref.watch(modelsControllerPod(ModelType.text));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Generation Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Options Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Topic
              _OptionItem(
                icon: Icons.topic_outlined,
                label: 'Topic',
                value: formState.topic.isNotEmpty
                    ? (formState.topic.length > 30
                          ? '${formState.topic.substring(0, 30)}...'
                          : formState.topic)
                    : 'Not set',
              ),
              // Slide Count
              _OptionItem(
                icon: Icons.format_list_numbered,
                label: 'Slides',
                value: '${formState.slideCount}',
              ),
              // Language
              _OptionItem(
                icon: Icons.language,
                label: 'Language',
                value: formState.language,
              ),
              // Model
              textModelsAsync.when(
                data: (models) => _OptionItem(
                  icon: Icons.psychology,
                  label: 'Model',
                  value: formState.outlineModel?.displayName ?? 'Default',
                ),
                loading: () => const _OptionItem(
                  icon: Icons.psychology,
                  label: 'Model',
                  value: 'Loading...',
                ),
                error: (_, _) => const _OptionItem(
                  icon: Icons.psychology,
                  label: 'Model',
                  value: 'Error',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Regenerate Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onRegenerate,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(isLoading ? 'Regenerating...' : 'Regenerate Outline'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays the outline with slide titles
class OutlineSummarySection extends StatelessWidget {
  final String outline;
  final VoidCallback onEdit;

  const OutlineSummarySection({
    super.key,
    required this.outline,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slideTitles = OutlineParser.extractSlideTitles(outline);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Generated Outline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...slideTitles.asMap().entries.map((entry) {
            final index = entry.key;
            final title = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Displays image model selection options
class ImageModelSection extends ConsumerWidget {
  const ImageModelSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formState = ref.watch(presentationFormControllerProvider);
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );
    final imageModelsAsync = ref.watch(modelsControllerPod(ModelType.image));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.image_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Image Generation Model',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          imageModelsAsync.when(
            data: (state) {
              final models = state.availableModels
                  .where((m) => m.isEnabled)
                  .toList();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: models.map((model) {
                  final isSelected = formState.imageModel?.id == model.id;
                  return ChoiceChip(
                    label: Text(model.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        formController.updateImageModel(model);
                      }
                    },
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isDark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load models',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Input field for content to avoid
class AvoidContentSection extends ConsumerWidget {
  final TextEditingController avoidContentController;

  const AvoidContentSection({super.key, required this.avoidContentController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.block_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Content to Avoid',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '(Optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: avoidContentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter topics or content you want to avoid...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (value) {
              ref
                  .read(presentationFormControllerProvider.notifier)
                  .updateAvoidContent(value);
            },
          ),
        ],
      ),
    );
  }
}

/// Bottom action bar with Edit Outline and Generate buttons
class PresentationCustomizationActionBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onEditOutline;
  final VoidCallback onGenerate;

  const PresentationCustomizationActionBar({
    super.key,
    required this.isLoading,
    required this.onEditOutline,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
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
          children: [
            // Edit Outline Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onEditOutline,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Outline'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Generate Button
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onGenerate,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(isLoading ? 'Generating...' : 'Generate'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Private helper widget for displaying a single option item
class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
