import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/generate/domain/repositories/models_repository.dart';

/// Mock implementation of ModelsRepository for Phase 1 testing
/// Returns hardcoded mock models for development
class MockModelsRepositoryImpl implements ModelsRepository {
  /// Mock models data
  static const _mockModels = [
    AIModel(
      id: 1,
      name: 'gpt-4',
      displayName: 'GPT-4',
      type: ModelType.text,
      isDefault: true,
      isEnabled: true,
    ),
    AIModel(
      id: 2,
      name: 'gpt-3.5-turbo',
      displayName: 'GPT-3.5 Turbo',
      type: ModelType.text,
      isDefault: false,
      isEnabled: true,
    ),
    AIModel(
      id: 3,
      name: 'claude-3',
      displayName: 'Claude 3',
      type: ModelType.text,
      isDefault: false,
      isEnabled: true,
    ),
    AIModel(
      id: 4,
      name: 'dall-e-3',
      displayName: 'DALL-E 3',
      type: ModelType.image,
      isDefault: true,
      isEnabled: true,
    ),
    AIModel(
      id: 5,
      name: 'stable-diffusion',
      displayName: 'Stable Diffusion',
      type: ModelType.image,
      isDefault: false,
      isEnabled: false,
    ),
  ];

  @override
  Future<List<AIModel>> getModels({ModelType? modelType}) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    var models = _mockModels;

    // Filter by type if specified
    if (modelType != null) {
      models = models.where((m) => m.type == modelType).toList();
    }

    // Return only enabled models
    return models.where((m) => m.isEnabled).toList();
  }

  @override
  Future<AIModel?> getDefaultModel(ModelType modelType) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _mockModels.firstWhere(
        (m) => m.type == modelType && m.isDefault && m.isEnabled,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AIModel?> getModelById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _mockModels.firstWhere((m) => m.id == id && m.isEnabled);
    } catch (e) {
      return null;
    }
  }
}
