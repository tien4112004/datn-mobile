import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';

/// Repository interface for fetching available AI models from backend
abstract class ModelsRepository {
  /// Fetch available AI models from backend (/models endpoint)
  /// Can optionally filter by modelType (TEXT or IMAGE)
  /// Returns only enabled models
  Future<List<AIModel>> getModels({ModelType? modelType});

  /// Get the default model for a specific type
  /// Returns null if no default model is found
  Future<AIModel?> getDefaultModel(ModelType modelType);

  /// Fetch a specific model by ID
  Future<AIModel?> getModelById(int id);
}
