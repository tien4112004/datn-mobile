import 'package:datn_mobile/features/projects/data/dto/slide_dto.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presentation_minimal_dto.g.dart';

@JsonSerializable()
class PresentationMinimalDto {
  String id;
  String title;
  DateTime? createdAt;
  DateTime? updatedAt;
  SlideDto? thumbnail;

  PresentationMinimalDto({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
  });

  factory PresentationMinimalDto.fromJson(Map<String, dynamic> json) =>
      _$PresentationMinimalDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationMinimalDtoToJson(this);
}

extension PresentationMinimalMapper on PresentationMinimalDto {
  PresentationMinimal toEntity() {
    return PresentationMinimal(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      thumbnail: thumbnail?.toEntity(),
    );
  }
}

extension PresentationMinimalDtoMapper on PresentationMinimal {
  PresentationMinimalDto toDto() {
    return PresentationMinimalDto(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      thumbnail: thumbnail?.toDto(),
    );
  }
}
