import 'package:datn_mobile/features/projects/domain/entity/mindmap.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mindmap_dto.g.dart';

@JsonSerializable()
class MindmapEdgeDto {
  final String id;
  final String type;
  final Map<String, dynamic>? extraFields;

  MindmapEdgeDto({required this.id, required this.type, this.extraFields});

  factory MindmapEdgeDto.fromJson(Map<String, dynamic> json) =>
      _$MindmapEdgeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MindmapEdgeDtoToJson(this);
}

@JsonSerializable()
class MindmapNodeDto {
  final String id;
  final String type;
  final Map<String, dynamic> extraFields;

  MindmapNodeDto({
    required this.id,
    required this.type,
    required this.extraFields,
  });

  factory MindmapNodeDto.fromJson(Map<String, dynamic> json) =>
      _$MindmapNodeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MindmapNodeDtoToJson(this);
}

@JsonSerializable()
class MindmapDto {
  final String id;
  final String title;
  final String? description;
  final List<MindmapNodeDto> nodes;
  final List<MindmapEdgeDto> edges;
  final DateTime createdAt;
  final DateTime updatedAt;

  MindmapDto({
    required this.id,
    required this.title,
    this.description,
    required this.nodes,
    required this.edges,
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
      nodes: nodes.map((nodeDto) {
        return MindmapNode(
          id: nodeDto.id,
          type: nodeDto.type,
          extraFields: nodeDto.extraFields,
        );
      }).toList(),
      edges: edges.map((edgeDto) {
        return MindmapEdge(
          id: edgeDto.id,
          type: edgeDto.type,
          extraFields: edgeDto.extraFields,
        );
      }).toList(),
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
      nodes: nodes.map((node) {
        return MindmapNodeDto(
          id: node.id,
          type: node.type,
          extraFields: node.extraFields,
        );
      }).toList(),
      edges: edges.map((edge) {
        return MindmapEdgeDto(
          id: edge.id,
          type: edge.type,
          extraFields: edge.extraFields,
        );
      }).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
