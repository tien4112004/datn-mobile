import 'package:json_annotation/json_annotation.dart';

part 'image_generation_request_dto.g.dart';

@JsonSerializable()
class ImageGenerationRequestDto {
  /// The text prompt to generate the image from
  final String prompt;

  /// The aspect ratio of the generated image
  /// default: "1:1"
  final String aspectRatio;

  /// The art style for the generated image
  final String artStyle;

  /// Additional art description
  final String artDescription;

  /// Additional theme description
  final String themeDescription;

  /// The AI model to use for generation
  final String model;

  /// The AI service provider
  final String provider;

  const ImageGenerationRequestDto({
    required this.prompt,
    required this.aspectRatio,
    required this.artStyle,
    required this.artDescription,
    required this.themeDescription,
    required this.model,
    required this.provider,
  });

  factory ImageGenerationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ImageGenerationRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImageGenerationRequestDtoToJson(this);

  ImageGenerationRequestDto copyWith({
    String? prompt,
    String? aspectRatio,
    String? artStyle,
    String? artDescription,
    String? themeDescription,
    String? model,
    String? provider,
  }) {
    return ImageGenerationRequestDto(
      prompt: prompt ?? this.prompt,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      artStyle: artStyle ?? this.artStyle,
      artDescription: artDescription ?? this.artDescription,
      themeDescription: themeDescription ?? this.themeDescription,
      model: model ?? this.model,
      provider: provider ?? this.provider,
    );
  }
}
