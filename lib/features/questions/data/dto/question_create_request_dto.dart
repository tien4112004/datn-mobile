import 'package:json_annotation/json_annotation.dart';

part 'question_create_request_dto.g.dart';

/// Request DTO for creating a question.
@JsonSerializable(includeIfNull: false)
class QuestionCreateRequestDto {
  final String title;
  final String type; // MULTIPLE_CHOICE, MATCHING, FILL_IN_BLANK, OPEN_ENDED
  final String
  difficulty; // KNOWLEDGE, COMPREHENSION, APPLICATION, ADVANCED_APPLICATION
  final String? explanation;
  final String? titleImageUrl;
  final Map<String, dynamic> data;
  final String? grade;
  final String? chapter;
  final String? subject;

  QuestionCreateRequestDto({
    required this.title,
    required this.type,
    required this.difficulty,
    this.explanation,
    this.titleImageUrl,
    required this.data,
    this.grade,
    this.chapter,
    this.subject,
  });

  factory QuestionCreateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionCreateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionCreateRequestDtoToJson(this);
}
