import 'package:datn_mobile/features/generate/data/repository/repository_provider.dart';
import 'package:datn_mobile/features/generate/domain/repositories/models_repository.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/states/models_state.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for fetching available AI models
/// Handles filtering by model type and selecting default models
class ModelsController extends AsyncNotifier<ModelsState> {
  late final ModelsRepository _repository;
  late ModelType modelType;

  @override
  Future<ModelsState> build() async {
    _repository = ref.watch(modelsRepositoryProvider);
    final models = await _repository.getModels(modelType: modelType);
    return ModelsState(availableModels: models);
  }

  /// Get the default model for a specific type
  Future<AIModel?> getDefaultModel() async {
    if (state.value == null) {
      return _repository.getDefaultModel(modelType);
    }

    return state.value?.availableModels.firstWhere(
      (model) => model.isDefault && model.type == modelType,
    );
  }

  /// Get a specific model by ID
  Future<AIModel?> getModelById(int id) async {
    if (state.value == null) {
      return _repository.getModelById(id);
    }

    return state.value?.availableModels.firstWhere(
      (model) => model.id == id && model.type == modelType,
    );
  }

  AIModel? getSelectedModelFor(ResourceType resourceType) {
    return modelType == ModelType.text
        ? state.value?.textModelState?.selectedModel
        : state.value?.imageModelState?.selectedModel;
  }
}
