import 'package:datn_mobile/features/generate/controllers/models_controller.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for ModelsController with optional type filter
/// Usage: ref.watch(modelsControllerPod(ModelType.text))
final modelsControllerPod =
    AsyncNotifierProvider.family<ModelsController, List<AIModel>, ModelType?>((
      modelType,
    ) {
      final controller = ModelsController();
      controller.modelType = modelType;
      return controller;
    });
