import 'package:json_annotation/json_annotation.dart';

part 'image_generation_response_dto.g.dart';

@JsonSerializable()
class ImageGenerationResponseDto {
  /// The URI of the generated image
  final String? url;

  /// The MIME type of the generated image
  final String? mimeType;

  /// The prompt used to generate the image
  final String? prompt;

  /// The timestamp when the image was created
  final String? created;

  const ImageGenerationResponseDto({
    this.url,
    this.mimeType,
    this.prompt,
    this.created,
  });

  factory ImageGenerationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ImageGenerationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImageGenerationResponseDtoToJson(this);
}
