import 'package:datn_mobile/features/projects/domain/entity/mindmap.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mindmap_dto.g.dart';

@JsonSerializable()
class MindmapDto {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  MindmapDto({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MindmapDto.fromJson(Map<String, dynamic> json) =>
      _$MindmapDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MindmapDtoToJson(this);
}

extension MindmapMapper on MindmapDto {
  Mindmap toEntity() {
    return Mindmap(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension MindmapDtoMapper on Mindmap {
  MindmapDto toDto() {
    return MindmapDto(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
