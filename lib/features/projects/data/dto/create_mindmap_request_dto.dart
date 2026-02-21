import 'package:json_annotation/json_annotation.dart';

part 'create_mindmap_request_dto.g.dart';

/// DTO for creating a new mindmap.
/// This matches the backend's CreateMindmapRequest type which omits
/// id, createdAt, and updatedAt fields.
@JsonSerializable(explicitToJson: true)
class CreateMindmapRequestDto {
  String title;
  String? description;
  @JsonKey(defaultValue: [])
  List<Map<String, dynamic>> nodes;
  @JsonKey(defaultValue: [])
  List<Map<String, dynamic>> edges;

  CreateMindmapRequestDto({
    required this.title,
    this.description,
    required this.nodes,
    required this.edges,
  });

  factory CreateMindmapRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateMindmapRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMindmapRequestDtoToJson(this);
}
