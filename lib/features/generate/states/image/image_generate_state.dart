import 'package:datn_mobile/features/generate/domain/entity/generated_image.dart';

/// State class representing the image generation state.
class ImageGenerateState {
  /// The generated image
  final GeneratedImage? generatedImage;

  const ImageGenerateState({this.generatedImage});

  factory ImageGenerateState.initial() => const ImageGenerateState();

  factory ImageGenerateState.success(GeneratedImage image) =>
      ImageGenerateState(generatedImage: image);

  bool get hasImage => generatedImage != null;
  bool get isLoading => generatedImage == null;

  ImageGenerateState copyWith({GeneratedImage? generatedImage}) {
    return ImageGenerateState(
      generatedImage: generatedImage ?? this.generatedImage,
    );
  }
}
