import 'package:json_annotation/json_annotation.dart';

part 'generate_matrix_request_dto.g.dart';

/// DTO for generating exam matrix.
/// Based on GenerateMatrixRequest schema from exams.yaml API.
@JsonSerializable()
class GenerateMatrixRequestDto {
  final String topic;
  @JsonKey(name: 'grade_level')
  final String gradeLevel;
  final String difficulty;
  final String? content;
  @JsonKey(name: 'total_questions')
  final int totalQuestions;
  @JsonKey(name: 'total_points')
  final int totalPoints;
  @JsonKey(name: 'question_types')
  final List<String>? questionTypes;

  GenerateMatrixRequestDto({
    required this.topic,
    required this.gradeLevel,
    required this.difficulty,
    this.content,
    required this.totalQuestions,
    required this.totalPoints,
    this.questionTypes,
  });

  factory GenerateMatrixRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GenerateMatrixRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateMatrixRequestDtoToJson(this);
}
