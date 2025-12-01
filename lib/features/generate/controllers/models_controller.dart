import 'package:datn_mobile/features/generate/data/repositories/repository_provider.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/generate/domain/repositories/models_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for fetching available AI models
/// Handles filtering by model type and selecting default models
class ModelsController extends AsyncNotifier<List<AIModel>> {
  late final ModelsRepository _repository;
  late ModelType? modelType;

  @override
  Future<List<AIModel>> build() async {
    _repository = ref.watch(modelsRepositoryProvider);
    return _repository.getModels(modelType: modelType);
  }

  /// Get the default model for a specific type
  Future<AIModel?> getDefaultModel(ModelType modelType) async {
    return _repository.getDefaultModel(modelType);
  }

  /// Get a specific model by ID
  Future<AIModel?> getModelById(int id) async {
    return _repository.getModelById(id);
  }
}
