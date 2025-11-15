import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/domain/entity/outline_entity.dart';

part 'outline_dto.g.dart';

@JsonSerializable()
class OutlineRequestDto {
  @JsonKey(name: 'topic')
  final String topic;
  @JsonKey(name: 'language')
  final String language;
  @JsonKey(name: 'model')
  final String model;
  @JsonKey(
    name: 'slide_count',
    fromJson: _slideCountFromJson,
    toJson: _slideCountToJson,
  )
  final int slideCount;
  @JsonKey(name: 'provider')
  final String provider;

  OutlineRequestDto({
    required this.topic,
    required this.language,
    required this.model,
    required this.slideCount,
    required this.provider,
  });

  factory OutlineRequestDto.fromJson(Map<String, dynamic> json) =>
      _$OutlineRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OutlineRequestDtoToJson(this);

  // Handle both 'slide_count' and 'slideCount' JSON keys
  static int _slideCountFromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static dynamic _slideCountToJson(int value) => value;
}

@JsonSerializable()
class OutlineResponseDto {
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'content')
  final String? content;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  OutlineResponseDto({this.id, this.content, this.createdAt});

  factory OutlineResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OutlineResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OutlineResponseDtoToJson(this);
}

// Mappers
extension OutlineRequestDtoMapper on OutlineRequest {
  OutlineRequestDto toDto() {
    return OutlineRequestDto(
      topic: topic,
      language: language,
      model: model,
      slideCount: slideCount,
      provider: provider,
    );
  }
}

extension OutlineResponseDtoMapper on OutlineResponse {
  OutlineResponseDto toDto() {
    return OutlineResponseDto(id: id, content: content, createdAt: createdAt);
  }
}

extension OutlineResponseMapper on OutlineResponseDto {
  OutlineResponse toEntity() {
    return OutlineResponse(id: id, content: content, createdAt: createdAt);
  }
}
