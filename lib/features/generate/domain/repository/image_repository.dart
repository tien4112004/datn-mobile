import 'package:datn_mobile/features/generate/data/dto/image_generation_request_dto.dart';
import 'package:datn_mobile/features/generate/domain/entity/generated_image.dart';

/// Abstract repository for image generation operations.
abstract class ImageRepository {
  /// Generates an image from a prompt using AI.
  Future<GeneratedImage> generateImage(ImageGenerationRequestDto request);
}
