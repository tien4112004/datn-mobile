import 'package:datn_mobile/features/generate/data/dto/model_response.dart';
import 'package:datn_mobile/features/generate/domain/repositories/models_repository.dart';
import 'package:datn_mobile/features/generate/data/source/models_remote_source.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';

/// Real implementation of ModelsRepository using API calls
class ModelsRepositoryImpl implements ModelsRepository {
  final ModelsRemoteSource _remoteSource;

  ModelsRepositoryImpl(this._remoteSource);

  @override
  Future<List<AIModel>> getModels({ModelType? modelType}) async {
    try {
      final response = await _remoteSource.getModels(
        modelType: modelType?.value,
      );

      if (response.data == null) {
        return [];
      }

      // Map response DTOs to domain entities
      return response.data!
          .map((dto) => dto.toEntity())
          .where((model) => model.isEnabled)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch models: $e');
    }
  }

  @override
  Future<AIModel?> getDefaultModel(ModelType modelType) async {
    try {
      final models = await getModels(modelType: modelType);

      try {
        return models.firstWhere((m) => m.isDefault);
      } catch (e) {
        // If no default found, return first available
        return models.isNotEmpty ? models.first : null;
      }
    } catch (e) {
      throw Exception('Failed to get default model: $e');
    }
  }

  @override
  Future<AIModel?> getModelById(int id) async {
    try {
      final response = await _remoteSource.getModelById(id);

      if (response.data == null || !response.data!.isEnabled) {
        return null;
      }

      return response.data!.toEntity();
    } catch (e) {
      throw Exception('Failed to get model by id: $e');
    }
  }
}
