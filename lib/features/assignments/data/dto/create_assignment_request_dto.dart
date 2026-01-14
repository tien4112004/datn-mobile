import 'package:json_annotation/json_annotation.dart';

part 'create_assignment_request_dto.g.dart';

/// DTO for creating a new exam.
/// Based on CreateExamRequest schema from assignments.yaml API.
@JsonSerializable()
class CreateExamRequestDto {
  final String title;
  final String? description;
  final String topic;
  @JsonKey(name: 'grade_level')
  final String gradeLevel;
  final String difficulty;
  @JsonKey(name: 'time_limit_minutes')
  final int? timeLimitMinutes;

  CreateExamRequestDto({
    required this.title,
    this.description,
    required this.topic,
    required this.gradeLevel,
    required this.difficulty,
    this.timeLimitMinutes,
  });

  factory CreateExamRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateExamRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateExamRequestDtoToJson(this);
}
