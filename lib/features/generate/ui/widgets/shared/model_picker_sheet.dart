import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet for selecting an AI model
/// Displays available enabled models and allows selection with callback
class ModelPickerSheet extends ConsumerWidget {
  final String title;
  final String? selectedModelName;
  final Translations t;
  final Function(AIModel) onModelSelected;
  final ModelType modelType;

  const ModelPickerSheet({
    super.key,
    required this.title,
    required this.selectedModelName,
    required this.t,
    required this.onModelSelected,
    required this.modelType,
  });

  static void show({
    required BuildContext context,
    required String title,
    required String? selectedModelName,
    required Translations t,
    required Function(AIModel) onModelSelected,
    required ModelType modelType,
  }) {
    PickerBottomSheet.show(
      context: context,
      title: title,
      child: ModelPickerSheet(
        title: title,
        selectedModelName: selectedModelName,
        t: t,
        onModelSelected: onModelSelected,
        modelType: modelType,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(modelsControllerPod(modelType));

    return modelsAsync.when(
      data: (state) {
        final models = state.availableModels.where((m) => m.isEnabled).toList();
        if (models.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(t.generate.presentationGenerate.noModelsAvailable),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: models.map((model) {
            final isSelected = selectedModelName == model.displayName;
            return ListTile(
              title: Text(model.displayName),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                onModelSelected(model);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(t.generate.presentationGenerate.failedToLoadModels),
      ),
    );
  }
}
