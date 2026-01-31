import 'package:AIPrimary/features/generate/domain/entity/generated_image.dart';

/// State class representing the image generation state.
class ImageGenerateState {
  /// The generated image
  final GeneratedImage? generatedImage;
  final String? errorMessage;

  const ImageGenerateState({this.generatedImage, this.errorMessage});

  factory ImageGenerateState.initial() => const ImageGenerateState();

  factory ImageGenerateState.success(GeneratedImage image) =>
      ImageGenerateState(generatedImage: image);

  factory ImageGenerateState.failure(String errorMessage) =>
      ImageGenerateState(errorMessage: errorMessage);

  bool get hasImage => generatedImage != null;
  bool get isLoading => generatedImage == null;

  ImageGenerateState copyWith({GeneratedImage? generatedImage}) {
    return ImageGenerateState(
      generatedImage: generatedImage ?? this.generatedImage,
    );
  }
}
