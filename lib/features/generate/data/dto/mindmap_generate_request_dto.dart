import 'package:json_annotation/json_annotation.dart';

part 'mindmap_generate_request_dto.g.dart';

@JsonSerializable()
class MindmapGenerateRequestDto {
  /// The main topic or subject for the mindmap generation
  /// minLength: 1, maxLength: 500
  final String topic;

  /// The AI model to use for generation
  final String model;

  /// The AI service provider
  final String provider;

  /// The language for the mindmap content (ISO 639-1 code)
  final String language;

  /// Maximum depth of the mindmap branches
  /// minimum: 1, maximum: 5, default: 3
  final int? maxDepth;

  /// Maximum number of branches per node
  /// minimum: 1, maximum: 10, default: 5
  final int? maxBranchesPerNode;

  /// The grade level for the content (max 50 chars)
  final String? grade;

  /// The subject area for the content (max 100 chars)
  final String? subject;

  const MindmapGenerateRequestDto({
    required this.topic,
    required this.model,
    required this.provider,
    required this.language,
    this.maxDepth,
    this.maxBranchesPerNode,
    this.grade,
    this.subject,
  });

  factory MindmapGenerateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MindmapGenerateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$MindmapGenerateRequestDtoToJson(this);
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
