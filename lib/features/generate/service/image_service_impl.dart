part of 'service_provider.dart';

class ImageServiceImpl implements ImageService {
  final ImageRepository _repository;

  ImageServiceImpl(this._repository);

  @override
  Future<GeneratedImage> generateImage({
    required String prompt,
    required AIModel model,
    String? aspectRatio,
    String? artStyle,
    String? artDescription,
    String? themeStyle,
    String? themeDescription,
  }) async {
    // Add business logic validations here
    if (prompt.trim().isEmpty) {
      throw ArgumentError('Prompt cannot be empty');
    }

    if (prompt.length > 1000) {
      throw ArgumentError('Prompt cannot exceed 1000 characters');
    }

    final request = ImageGenerationRequestDto(
      prompt: prompt.trim(),
      aspectRatio: aspectRatio,
      artStyle: artStyle,
      artDescription: artDescription,
      themeStyle: themeStyle,
      themeDescription: themeDescription,
      model: model.name,
      provider: model.provider,
    );

    return _repository.generateImage(request);
  }
}
