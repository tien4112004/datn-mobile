import 'package:datn_mobile/features/generate/controllers/models_controller_pod.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget for selecting an AI model from a dynamic dropdown
/// Fetches available models based on model type
class ModelSelector extends ConsumerWidget {
  final ModelType modelType; // Type of models to fetch (TEXT or IMAGE)
  final AIModel? selectedModel; // Currently selected model
  final ValueChanged<AIModel> onModelChanged; // Callback when model is selected

  const ModelSelector({
    super.key,
    required this.modelType,
    required this.selectedModel,
    required this.onModelChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch models for this type
    final modelsAsync = ref.watch(modelsControllerPod(modelType));

    return modelsAsync.when(
      data: (models) {
        if (models.isEmpty) {
          return const SizedBox(
            height: 56,
            child: Center(child: Text('No models available')),
          );
        }

        return DropdownButton<AIModel>(
          isExpanded: true,
          value: selectedModel ?? models.first,
          onChanged: (AIModel? newModel) {
            if (newModel != null) {
              onModelChanged(newModel);
            }
          },
          items: models.map((AIModel model) {
            return DropdownMenuItem<AIModel>(
              value: model,
              child: Text(model.displayName, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox(
        height: 56,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stackTrace) => SizedBox(
        height: 56,
        child: Center(
          child: Text(
            'Failed to load models',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}
