import 'package:json_annotation/json_annotation.dart';

part 'chapter_response_dto.g.dart';

@JsonSerializable()
class ChapterResponseDto {
  final String id;
  final String name;
  final String? grade;
  final String? subject;
  final int? sortOrder;

  const ChapterResponseDto({
    required this.id,
    required this.name,
    this.grade,
    this.subject,
    this.sortOrder,
  });

  factory ChapterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChapterResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterResponseDtoToJson(this);
}
