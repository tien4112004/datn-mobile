import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/presentation_generate/domain/entity/presentation_entity.dart';
import 'package:datn_mobile/features/presentation_generate/enum/presentation_enums.dart';

part 'presentation_dto.g.dart';

@JsonSerializable()
class PresentationRequestDto {
  @JsonKey(name: 'model')
  final String model;
  @JsonKey(name: 'grade')
  final String grade;
  @JsonKey(name: 'theme')
  final String theme;
  @JsonKey(name: 'slides')
  final int? slides;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'avoid')
  final String? avoid;
  @JsonKey(name: 'attachments')
  final List<String>? attachments;

  PresentationRequestDto({
    required this.model,
    required this.grade,
    required this.theme,
    this.slides,
    required this.description,
    this.avoid,
    this.attachments,
  });

  factory PresentationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PresentationRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationRequestDtoToJson(this);
}

@JsonSerializable()
class PresentationResponseDto {
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

  PresentationResponseDto({
    this.id,
    this.title,
    this.content,
    this.slides,
    this.createdAt,
  });

  factory PresentationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PresentationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationResponseDtoToJson(this);
}

// Mappers
extension PresentationRequestMapper on PresentationRequestDto {
  PresentationRequest toEntity() {
    return PresentationRequest(
      model: PresentationModel.values.firstWhere(
        (e) => e.displayName == model,
        orElse: () => PresentationModel.fast,
      ),
      grade: PresentationGrade.values.firstWhere(
        (e) => e.displayName == grade,
        orElse: () => PresentationGrade.grade1,
      ),
      theme: PresentationTheme.values.firstWhere(
        (e) => e.displayName == theme,
        orElse: () => PresentationTheme.lorems,
      ),
      slides: slides,
      description: description,
      avoid: avoid,
      attachments: attachments,
    );
  }
}

extension PresentationRequestDtoMapper on PresentationRequest {
  PresentationRequestDto toDto() {
    return PresentationRequestDto(
      model: model.displayName,
      grade: grade.displayName,
      theme: theme.displayName,
      slides: slides,
      description: description,
      avoid: avoid,
      attachments: attachments,
    );
  }
}

extension PresentationResponseMapper on PresentationResponseDto {
  PresentationResponse toEntity() {
    return PresentationResponse(
      id: id,
      title: title,
      content: content,
      slides: slides,
      createdAt: createdAt,
    );
  }
}

extension PresentationResponseDtoMapper on PresentationResponse {
  PresentationResponseDto toDto() {
    return PresentationResponseDto(
      id: id,
      title: title,
      content: content,
      slides: slides,
      createdAt: createdAt,
    );
  }
}