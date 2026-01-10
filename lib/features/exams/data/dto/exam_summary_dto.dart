import 'package:datn_mobile/features/exams/domain/entity/exam_entity.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_summary_dto.g.dart';

/// DTO for exam summary in list view.
/// Based on ExamSummary schema from exams.yaml API.
@JsonSerializable()
class ExamSummaryDto {
  @JsonKey(name: 'exam_id')
  final String examId;
  final String title;
  final String topic;
  @JsonKey(name: 'grade_level')
  final String gradeLevel;
  final String status;
  @JsonKey(name: 'total_questions')
  final int totalQuestions;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ExamSummaryDto({
    required this.examId,
    required this.title,
    required this.topic,
    required this.gradeLevel,
    required this.status,
    required this.totalQuestions,
    required this.createdAt,
  });

  factory ExamSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ExamSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamSummaryDtoToJson(this);
}

/// Extension for mapping DTO to domain entity (partial).
extension ExamSummaryMapper on ExamSummaryDto {
  ExamEntity toEntity({
    required String teacherId,
    String? description,
    required Difficulty difficulty,
    required int totalPoints,
    int? timeLimitMinutes,
  }) => ExamEntity(
    examId: examId,
    teacherId: teacherId,
    title: title,
    description: description,
    topic: topic,
    gradeLevel: GradeLevel.fromName(gradeLevel),
    status: ExamStatus.fromName(status),
    difficulty: difficulty,
    totalQuestions: totalQuestions,
    totalPoints: totalPoints,
    timeLimitMinutes: timeLimitMinutes,
    createdAt: createdAt,
  );
}
