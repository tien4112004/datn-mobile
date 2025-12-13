import 'package:datn_mobile/features/generate/data/dto/image_generation_request_dto.dart';
import 'package:datn_mobile/features/generate/data/source/image_remote_source.dart';
import 'package:datn_mobile/features/generate/domain/entity/generated_image.dart';
import 'package:datn_mobile/features/generate/domain/repository/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageRemoteSource _remoteSource;

  ImageRepositoryImpl(this._remoteSource);

  @override
  Future<GeneratedImage> generateImage(
    ImageGenerationRequestDto request,
  ) async {
    request = request.copyWith(model: 'gemini-2.5-flash-image-preview');
    final response = await _remoteSource.generateImage(request);

    if (response.data == null) {
      throw Exception('Failed to generate image: No data returned');
    }

    // Map response DTO to domain entity
    return GeneratedImage(
      url: response.data!.url,
      mimeType: response.data!.mimeType,
      prompt: response.data!.prompt,
      created: response.data!.created,
    );
  }
}
