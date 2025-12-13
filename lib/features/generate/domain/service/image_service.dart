import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/domain/entity/generated_image.dart';

/// Abstract service interface for image generation.
abstract interface class ImageService {
  /// Generates an image from a prompt using AI.
  Future<GeneratedImage> generateImage({
    required String prompt,
    required AIModel model,
    String? aspectRatio,
    String? artStyle,
    String? artDescription,
    String? themeStyle,
    String? themeDescription,
  });
}
