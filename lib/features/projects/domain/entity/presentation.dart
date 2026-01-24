import 'package:json_annotation/json_annotation.dart';

part 'presentation.g.dart';

@JsonSerializable()
class Presentation {
  String id;
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  String? thumbnail;

  Presentation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    this.thumbnail,
  });

  factory Presentation.fromJson(Map<String, dynamic> json) =>
      _$PresentationFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationToJson(this);
}
