import 'package:json_annotation/json_annotation.dart';

part 'image_generation_response_dto.g.dart';

@JsonSerializable()
class ImageGenerationResponseDto {
  final List<ImageResponse>? images;

  ImageGenerationResponseDto({this.images});

  factory ImageGenerationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ImageGenerationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImageGenerationResponseDtoToJson(this);
}

@JsonSerializable()
class ImageResponse {
  @JsonKey(name: 'cdnUrl')
  final String url;
  final int id;

  ImageResponse({required this.url, required this.id});

  factory ImageResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ImageResponseToJson(this);
}
