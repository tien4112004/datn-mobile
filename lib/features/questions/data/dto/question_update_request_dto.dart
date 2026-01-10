import 'package:json_annotation/json_annotation.dart';

part 'question_update_request_dto.g.dart';

/// Request DTO for updating a question.
/// All fields are optional, only provide what needs updating.
@JsonSerializable(includeIfNull: false)
class QuestionUpdateRequestDto {
  final String? title;
  final String? type;
  final String? difficulty;
  final String? explanation;
  final String? titleImageUrl;
  final int? points;
  final Map<String, dynamic>? data;

  QuestionUpdateRequestDto({
    this.title,
    this.type,
    this.difficulty,
    this.explanation,
    this.titleImageUrl,
    this.points,
    this.data,
  });

  factory QuestionUpdateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionUpdateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionUpdateRequestDtoToJson(this);
}
