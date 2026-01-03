import 'package:datn_mobile/features/exams/domain/entity/exam_entity.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_response_dto.g.dart';

/// DTO for exam response (create/duplicate).
/// Based on ExamResponse schema from exams.yaml API.
@JsonSerializable()
class ExamResponseDto {
  @JsonKey(name: 'exam_id')
  final String examId;
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  final String title;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ExamResponseDto({
    required this.examId,
    required this.teacherId,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  factory ExamResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ExamResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamResponseDtoToJson(this);
}

/// Extension for mapping DTO to domain entity (partial).
extension ExamResponseMapper on ExamResponseDto {
  ExamEntity toEntity({
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int totalQuestions = 0,
    int totalPoints = 0,
  }) => ExamEntity(
    examId: examId,
    teacherId: teacherId,
    title: title,
    description: description,
    topic: topic,
    gradeLevel: gradeLevel,
    status: ExamStatus.fromString(status),
    difficulty: difficulty,
    totalQuestions: totalQuestions,
    totalPoints: totalPoints,
    createdAt: createdAt,
  );
}
