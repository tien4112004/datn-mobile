import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/domain/entity/presentation_generation_entity.dart';

part 'presentation_generation_dto.g.dart';

@JsonSerializable()
class PresentationGenerationRequestDto {
  @JsonKey(name: 'outline')
  final String outline;
  @JsonKey(name: 'model')
  final String model;
  @JsonKey(name: 'theme')
  final String theme;
  @JsonKey(name: 'avoid')
  final String? avoid;

  PresentationGenerationRequestDto({
    required this.outline,
    required this.model,
    required this.theme,
    this.avoid,
  });

  factory PresentationGenerationRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => _$PresentationGenerationRequestDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PresentationGenerationRequestDtoToJson(this);
}

@JsonSerializable()
class PresentationGenerationResponseDto {
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'content')
  final String? content;
  @JsonKey(name: 'slides')
  final List<String>? slides;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  PresentationGenerationResponseDto({
    this.id,
    this.title,
    this.content,
    this.slides,
    this.createdAt,
  });

  factory PresentationGenerationResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$PresentationGenerationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PresentationGenerationResponseDtoToJson(this);
}

// Mappers
extension PresentationGenerationRequestDtoMapper
    on PresentationGenerationRequest {
  PresentationGenerationRequestDto toDto() {
    return PresentationGenerationRequestDto(
      outline: outline,
      model: model,
      theme: theme,
      avoid: avoid,
    );
  }
}

extension PresentationGenerationResponseDtoMapper
    on PresentationGenerationResponse {
  PresentationGenerationResponseDto toDto() {
    return PresentationGenerationResponseDto(
      id: id,
      title: title,
      content: content,
      slides: slides,
      createdAt: createdAt,
    );
  }
}

extension PresentationGenerationResponseMapper
    on PresentationGenerationResponseDto {
  PresentationGenerationResponse toEntity() {
    return PresentationGenerationResponse(
      id: id,
      title: title,
      content: content,
      slides: slides,
      createdAt: createdAt,
    );
  }
}
