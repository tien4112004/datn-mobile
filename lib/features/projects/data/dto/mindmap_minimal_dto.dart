import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mindmap_minimal_dto.g.dart';

@JsonSerializable()
class MindmapMinimalDto {
  final String id;
  final String title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? thumbnail;

  MindmapMinimalDto({
    required this.id,
    required this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
  });

  factory MindmapMinimalDto.fromJson(Map<String, dynamic> json) =>
      _$MindmapMinimalDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MindmapMinimalDtoToJson(this);
}

extension MindmapMinimalMapper on MindmapMinimalDto {
  MindmapMinimal toEntity() {
    return MindmapMinimal(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      thumbnail: thumbnail,
    );
  }
}

extension MindmapMinimalDtoMapper on MindmapMinimal {
  MindmapMinimalDto toDto() {
    return MindmapMinimalDto(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      thumbnail: thumbnail,
    );
  }
}
