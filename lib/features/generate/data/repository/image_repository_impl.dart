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
    final response = await _remoteSource.generateImage(request);

    if (response.data == null) {
      throw Exception('Failed to generate image: No data returned');
    }

    final generatedImage = response.data!.images?.firstOrNull;

    if (generatedImage == null) {
      throw Exception('Failed to generate image: No images in response');
    }

    // Map response DTO to domain entity
    return GeneratedImage.fromRequestDto(
      request,
    ).copyWith(url: response.data!.images!.first.url);
  }
}
