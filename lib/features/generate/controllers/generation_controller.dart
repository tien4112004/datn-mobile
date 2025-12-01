import 'package:datn_mobile/features/generate/controllers/generation_state.dart';
import 'package:datn_mobile/features/generate/data/repositories/repository_provider.dart';
import 'package:datn_mobile/features/generate/domain/entities/generation_config.dart';
import 'package:datn_mobile/features/generate/domain/entities/generation_result.dart';
import 'package:datn_mobile/features/generate/domain/repositories/generation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for managing content generation state and logic
/// Handles presentations, images, mindmaps, etc.
class GenerationController extends AsyncNotifier<GenerationState> {
  late final GenerationRepository _repository;

  @override
  Future<GenerationState> build() async {
    _repository = ref.watch(generationRepositoryProvider);
    return GenerationState.initial();
  }

  /// Generate content based on configuration
  /// Validates config before generation
  /// Updates state with loading, success, or error
  Future<void> generate(GenerationConfig config) async {
    // Validate configuration
    if (!config.isValid) {
      state = AsyncValue.data(
        GenerationState.error(
          'Invalid configuration: Please check all required fields',
        ),
      );
      return;
    }

    // Set loading state
    state = const AsyncValue.loading();

    // Generate content with error handling
    state =
        await AsyncValue.guard(() async {
          final result = await _repository.generate(config);
          return GenerationState.success(result);
        }).then((asyncValue) {
          return asyncValue.whenOrNull(
                error: (error, stackTrace) {
                  return AsyncValue.data(
                    GenerationState.error(error.toString()),
                  );
                },
              ) ??
              asyncValue;
        });
  }

  /// Generate content with streaming
  /// Yields partial results as they arrive from the API
  /// Updates state with accumulated content
  Stream<String> generateStream(GenerationConfig config) async* {
    // Validate configuration
    if (!config.isValid) {
      yield '';
      state = AsyncValue.data(
        GenerationState.error(
          'Invalid configuration: Please check all required fields',
        ),
      );
      return;
    }

    // Set loading state
    state = const AsyncValue.loading();

    try {
      final buffer = StringBuffer();

      // Stream content from repository
      await for (final chunk in _repository.generateStream(config)) {
        buffer.write(chunk);
        yield chunk;

        // Update state with partial result
        state = AsyncValue.data(
          GenerationState.success(
            GenerationResult(
              content: buffer.toString(),
              generatedAt: DateTime.now(),
              resourceType: config.resourceType,
            ),
          ),
        );
      }
    } catch (e) {
      state = AsyncValue.data(GenerationState.error(e.toString()));
      yield '';
    }
  }

  /// Reset generation state
  void reset() {
    state = AsyncValue.data(GenerationState.initial());
  }
}
