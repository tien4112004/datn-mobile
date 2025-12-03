import 'package:datn_mobile/features/generate/controllers/pods/models_controller_pod.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/generate/view/widgets/common/flex_dropdown_field.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Model selector field using flex_dropdown
/// Fetches available models based on model type and displays them in a dropdown
class ModelSelectorField extends ConsumerWidget {
  final ResourceType resourceType;
  final AIModel? selectedModel;
  final ValueChanged<AIModel> onModelChanged;
  final String label;

  const ModelSelectorField({
    super.key,
    required this.resourceType,
    required this.selectedModel,
    required this.onModelChanged,
    this.label = 'AI Model',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(
      modelsControllerPod(resourceType.modelTypeValue),
    );

    return modelsAsync.when(
      data: (modelState) {
        final models = modelState.availableModels;
        if (models.isEmpty) {
          return SizedBox(
            height: 70,
            child: Center(
              child: Text(
                'No models available',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }

        final currentModel =
            selectedModel ?? models.where((m) => m.isDefault).first;
        final modelOptions = models.map((m) => m.displayName).toList();

        return FlexDropdownField(
          label: label,
          items: modelOptions,
          currentValue: currentModel.displayName,
          displayText: currentModel.displayName,
          icon: LucideIcons.zap,
          onChanged: (displayName) {
            final model = models.firstWhere(
              (m) => m.displayName == displayName,
            );
            onModelChanged(model);
          },
        );
      },
      loading: () => SizedBox(
        height: 70,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
      error: (error, stackTrace) => SizedBox(
        height: 70,
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
