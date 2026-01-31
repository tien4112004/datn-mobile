import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/domain/entity/generated_image.dart';

/// Abstract service interface for image generation.
abstract interface class ImageService {
  /// Generates an image from a prompt using AI.
  Future<GeneratedImage> generateImage({
    required String prompt,
    required AIModel model,
    required String aspectRatio,
    required String artStyle,
    required String artDescription,
    required String themeDescription,
  });
}
