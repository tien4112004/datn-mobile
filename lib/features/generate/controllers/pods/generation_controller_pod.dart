import 'package:datn_mobile/features/generate/controllers/generation_controller.dart';
import 'package:datn_mobile/features/generate/controllers/states/generation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for GenerationController
final generationControllerPod =
    AsyncNotifierProvider<GenerationController, GenerationState>(
      GenerationController.new,
    );
