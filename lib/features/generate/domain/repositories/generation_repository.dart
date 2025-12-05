import 'package:datn_mobile/features/generate/domain/entities/generation_config.dart';
import 'package:datn_mobile/features/generate/domain/entities/generation_result.dart';

/// Repository interface for generating content (presentations, images, mindmaps)
/// Supports multiple resource types
abstract class GenerationRepository {
  /// Generate content based on the provided configuration
  /// Returns a GenerationResult with the generated content
  Future<GenerationResult> generate(GenerationConfig config);

  Future<GenerationResult> generateOutline(GenerationConfig config);

  /// Stream content generation for real-time updates
  /// Yields chunks of generated content as they arrive from the API
  /// Used for presentation outlines, image generation, etc.
  Stream<String> generateStream(GenerationConfig config);

  // TODO: Phase 2b - Full presentation generation from outline
  // Future<Presentation> generatePresentation(String outline);
}
