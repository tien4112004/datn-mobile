part of '../controller_provider.dart';

/// Provider for ModelsController with optional type filter
/// Usage: ref.watch(modelsControllerPod(ModelType.text))
final modelsControllerPod =
    AsyncNotifierProvider.family<ModelsController, ModelsState, ModelType>((
      modelType,
    ) {
      final controller = ModelsController();
      controller.modelType = modelType;
      return controller;
    });

/// Notifier for managing text model state
class _TextModelNotifier extends StateNotifier<TextModelState> {
  _TextModelNotifier(super.initialState);

  void selectModel(AIModel model) {
    state = state.copyWith(selectedModel: model);
  }

  void clearSelection() {
    state = state.copyWith(selectedModel: null);
  }
}

/// Notifier for managing image model state
class _ImageModelNotifier extends StateNotifier<ImageModelState> {
  _ImageModelNotifier(super.initialState);

  void selectModel(AIModel model) {
    state = state.copyWith(selectedModel: model);
  }

  void clearSelection() {
    state = state.copyWith(selectedModel: null);
  }
}

/// Provider for text model selection state
final textModelStatePod =
    StateNotifierProvider<_TextModelNotifier, TextModelState>((ref) {
      final modelsState = ref.watch(modelsControllerPod(ModelType.text));
      AIModel? defaultModel;
      try {
        defaultModel = modelsState.value?.availableModels.firstWhere(
          (model) => model.isDefault,
        );
      } catch (e) {
        defaultModel = null;
      }

      return _TextModelNotifier(TextModelState(selectedModel: defaultModel));
    });

/// Provider for image model selection state
final imageModelStatePod =
    StateNotifierProvider<_ImageModelNotifier, ImageModelState>((ref) {
      final modelsState = ref.watch(modelsControllerPod(ModelType.image));
      AIModel? defaultModel;
      try {
        defaultModel = modelsState.value?.availableModels.firstWhere(
          (model) => model.isDefault,
        );
      } catch (e) {
        defaultModel = null;
      }

      return _ImageModelNotifier(ImageModelState(selectedModel: defaultModel));
    });
