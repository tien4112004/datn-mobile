import 'package:AIPrimary/features/generate/data/repository/repository_provider.dart';
import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/utils/provider_logo_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Displays generation settings like topic, slide count, language, and model
/// Displays generation settings like topic, slide count, language, and model
class GenerationOptionsSection extends ConsumerWidget {
  final AsyncValue generateStateAsync;
  final VoidCallback onRegenerate;

  const GenerationOptionsSection({
    super.key,
    required this.generateStateAsync,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
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
                LucideIcons.settings,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                t.generate.customization.generationSettings,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
                icon: LucideIcons.typeOutline,
                label: t.generate.customization.topic,
                value: formState.topic.isNotEmpty
                    ? (formState.topic.length > 30
                          ? '${formState.topic.substring(0, 30)}...'
                          : formState.topic)
                    : t.generate.customization.notSet,
              ),
              // Slide Count
              _OptionItem(
                icon: LucideIcons.listOrdered,
                label: t.generate.customization.slides,
                value: '${formState.slideCount}',
              ),
              // Language
              _OptionItem(
                icon: LucideIcons.languages,
                label: t.generate.customization.language,
                value: formState.language,
              ),
              // Model
              textModelsAsync.easyWhen(
                data: (models) => _OptionItem(
                  icon: LucideIcons.bot,
                  label: t.generate.customization.model,
                  value:
                      formState.outlineModel?.displayName ??
                      t.generate.customization.notSet,
                  logoPath: formState.outlineModel != null
                      ? ProviderLogoUtils.getLogoPath(
                          formState.outlineModel!.provider,
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Regenerate Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: generateStateAsync.isLoading ? null : onRegenerate,
              icon: generateStateAsync.easyWhen(
                data: (_) => const Icon(LucideIcons.refreshCcw, size: 18),
                loadingWidget: () => const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                skipLoadingOnRefresh: false,
              ),
              label: generateStateAsync.easyWhen(
                data: (_) => Text(t.generate.customization.regenerateOutline),
                loadingWidget: () =>
                    Text(t.generate.customization.regenerating),
                skipLoadingOnRefresh: false,
              ),
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
class OutlineSummarySection extends ConsumerWidget {
  final String outline;
  final VoidCallback onEdit;

  const OutlineSummarySection({
    super.key,
    required this.outline,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parser = ref.read(outlineParserRepositoryProvider);
    final slideTitles = parser.extractSlideTitles(outline);

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
              Text(
                t.generate.customization.generatedOutline,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(LucideIcons.pen, size: 16),
                label: Text(t.generate.customization.edit),
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
    late final t = ref.watch(translationsPod);
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
              Text(
                t.generate.customization.imageGenerationModel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          imageModelsAsync.easyWhen(
            data: (state) {
              final models = state.availableModels
                  .where((m) => m.isEnabled)
                  .toList();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: models.map((model) {
                  final isSelected = formState.imageModel?.id == model.id;
                  final logoPath = ProviderLogoUtils.getLogoPath(
                    model.provider,
                  );
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(logoPath, width: 16, height: 16),
                        const SizedBox(width: 8),
                        Text(model.displayName),
                      ],
                    ),
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
            loadingWidget: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (error, stack) => Padding(
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
    final t = ref.watch(translationsPod);

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
              Text(
                t.generate.customization.contentToAvoid,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                t.generate.customization.optional,
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
              hintText: t.generate.customization.enterContentToAvoid,
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
class PresentationCustomizationActionBar extends ConsumerWidget {
  final AsyncValue generateStateAsync;
  final VoidCallback onEditOutline;
  final VoidCallback onGenerate;

  const PresentationCustomizationActionBar({
    super.key,
    required this.generateStateAsync,
    required this.onEditOutline,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = ref.watch(translationsPod);

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
            const SizedBox(width: 12),
            // Generate Button
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: generateStateAsync.isLoading ? null : onGenerate,
                icon: generateStateAsync.easyWhen(
                  data: (_) => const Icon(LucideIcons.sparkle),
                  loadingWidget: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  skipLoadingOnRefresh: false,
                ),
                label: generateStateAsync.easyWhen(
                  data: (_) => Text(t.generate.customization.generate),
                  loadingWidget: () =>
                      Text(t.generate.customization.generating),
                  skipLoadingOnRefresh: false,
                ),
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
  final String? logoPath;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.value,
    this.logoPath,
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
          if (logoPath != null)
            Image.asset(logoPath!, width: 16, height: 16)
          else
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
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
