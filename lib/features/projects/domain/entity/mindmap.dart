import 'package:json_annotation/json_annotation.dart';

part 'mindmap.g.dart';

@JsonSerializable()
class Mindmap {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? thumbnail;

  Mindmap({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnail,
  });

  Mindmap copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnail,
  }) {
    return Mindmap(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  factory Mindmap.fromJson(Map<String, dynamic> json) =>
      _$MindmapFromJson(json);

  Map<String, dynamic> toJson() => _$MindmapToJson(this);
}
