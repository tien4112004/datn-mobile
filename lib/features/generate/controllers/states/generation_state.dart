import 'package:datn_mobile/features/generate/domain/entities/generation_result.dart';

/// State for content generation (presentations, images, mindmaps, etc.)
class GenerationState {
  final GenerationResult? result;
  final bool isGenerating;
  final String? errorMessage;

  const GenerationState({
    this.result,
    this.isGenerating = false,
    this.errorMessage,
  });

  GenerationState copyWith({
    GenerationResult? result,
    bool? isGenerating,
    String? errorMessage,
  }) {
    return GenerationState(
      result: result ?? this.result,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Initial state
  factory GenerationState.initial() {
    return const GenerationState();
  }

  /// Loading state
  factory GenerationState.loading() {
    return const GenerationState(isGenerating: true);
  }

  /// Success state
  factory GenerationState.success(GenerationResult result) {
    return GenerationState(result: result, isGenerating: false);
  }

  /// Error state
  factory GenerationState.error(String message) {
    return GenerationState(errorMessage: message, isGenerating: false);
  }

  @override
  String toString() =>
      'GenerationState(isGenerating: $isGenerating, hasResult: ${result != null}, error: $errorMessage)';
}
