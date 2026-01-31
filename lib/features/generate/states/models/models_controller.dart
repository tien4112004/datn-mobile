import 'package:AIPrimary/features/generate/data/repository/repository_provider.dart';
import 'package:AIPrimary/features/generate/domain/repositories/models_repository.dart';
import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/states/models/models_state.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for fetching available AI models
/// Handles filtering by model type and selecting default models
class ModelsController extends AsyncNotifier<ModelsState> {
  ModelsRepository get _repository => ref.read(modelsRepositoryProvider);
  late ModelType modelType;

  @override
  Future<ModelsState> build() async {
    final repository = _repository;
    final models = await repository.getModels(modelType: modelType);
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
