import 'package:datn_mobile/features/generate/data/dto/image_generation_request_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated_image.g.dart';

/// Entity representing a generated image.
@JsonSerializable()
class GeneratedImage {
  /// The URI/URL of the generated image
  final String url;

  /// The MIME type of the generated image (e.g., image/png)
  final String? mimeType;

  /// The prompt used to generate the image
  final String prompt;

  /// The art style for the generated image
  final String artStyle;

  /// Additional art description
  final String artDescription;

  /// Additional theme description
  final String themeDescription;

  /// The AI model used to generate the image
  final String model;

  /// The aspect ratio of the generated image
  final String aspectRatio;

  const GeneratedImage({
    required this.url,
    this.mimeType,
    required this.prompt,
    required this.model,
    required this.aspectRatio,
    required this.artStyle,
    required this.artDescription,
    required this.themeDescription,
  });

  GeneratedImage copyWith({
    String? url,
    String? mimeType,
    String? prompt,
    String? model,
    String? aspectRatio,
    String? artStyle,
    String? artDescription,
    String? themeDescription,
  }) {
    return GeneratedImage(
      url: url ?? this.url,
      mimeType: mimeType ?? this.mimeType,
      prompt: prompt ?? this.prompt,
      model: model ?? this.model,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      artStyle: artStyle ?? this.artStyle,
      artDescription: artDescription ?? this.artDescription,
      themeDescription: themeDescription ?? this.themeDescription,
    );
  }

  Map<String, dynamic> toJson() => _$GeneratedImageToJson(this);

  factory GeneratedImage.fromJson(Map<String, dynamic> json) =>
      _$GeneratedImageFromJson(json);

  factory GeneratedImage.fromRequestDto(ImageGenerationRequestDto request) {
    return GeneratedImage(
      url: '',
      prompt: request.prompt,
      model: request.model,
      aspectRatio: request.aspectRatio,
      artStyle: request.artStyle,
      artDescription: request.artDescription,
      themeDescription: request.themeDescription,
    );
  }
}
