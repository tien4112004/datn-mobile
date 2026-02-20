import 'package:json_annotation/json_annotation.dart';

part 'generate_questions_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class GenerateQuestionsRequestDto {
  final String topic;
  final String grade;
  final String subject;
  @JsonKey(name: 'questionsPerDifficulty')
  final Map<String, int> questionsPerDifficulty;
  @JsonKey(name: 'questionTypes')
  final List<String> questionTypes;
  final String? provider;
  final String? model;
  final String? prompt;

  GenerateQuestionsRequestDto({
    required this.topic,
    required this.grade,
    required this.subject,
    required this.questionsPerDifficulty,
    required this.questionTypes,
    this.provider,
    this.model,
    this.prompt,
  });

  factory GenerateQuestionsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GenerateQuestionsRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateQuestionsRequestDtoToJson(this);
}
