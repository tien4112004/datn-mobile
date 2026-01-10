import 'package:json_annotation/json_annotation.dart';

part 'question_create_request_dto.g.dart';

/// Request DTO for creating a question.
@JsonSerializable()
class QuestionCreateRequestDto {
  final String title;
  final String type; // MULTIPLE_CHOICE, MATCHING, FILL_IN_THE_BLANK, OPEN_ENDED
  final String
  difficulty; // KNOWLEDGE, COMPREHENSION, APPLICATION, ADVANCED_APPLICATION
  final String? explanation;
  final String? titleImageUrl;
  final int? points;
  final Map<String, dynamic> data;

  QuestionCreateRequestDto({
    required this.title,
    required this.type,
    required this.difficulty,
    this.explanation,
    this.titleImageUrl,
    this.points,
    required this.data,
  });

  factory QuestionCreateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionCreateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionCreateRequestDtoToJson(this);
}
