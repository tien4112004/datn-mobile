import 'package:json_annotation/json_annotation.dart';

part 'mindmap_node_content_dto.g.dart';

/// A node in the mindmap hierarchy with recursive children structure.
/// Used for both generate response and mindmap content.
@JsonSerializable()
class MindmapNodeContentDto {
  /// Text content of the node
  final String content;

  /// Child nodes branching from this node
  final List<MindmapNodeContentDto>? children;

  const MindmapNodeContentDto({required this.content, this.children});

  factory MindmapNodeContentDto.fromJson(Map<String, dynamic> json) =>
      _$MindmapNodeContentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MindmapNodeContentDtoToJson(this);
}
