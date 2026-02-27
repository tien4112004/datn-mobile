import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_summary_dto.g.dart';

/// DTO for assignment summary in list view.
/// Based on ExamSummary schema from assignments.yaml API.
@JsonSerializable()
class ExamSummaryDto {
  @JsonKey(name: 'assignment_id')
  final String assignmentId;
  final String title;
  final String subject;
  @JsonKey(name: 'grade_level')
  final String gradeLevel;
  @JsonKey(name: 'total_questions')
  final int totalQuestions;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ExamSummaryDto({
    required this.assignmentId,
    required this.title,
    required this.subject,
    required this.gradeLevel,
    required this.totalQuestions,
    required this.createdAt,
  });

  factory ExamSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ExamSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamSummaryDtoToJson(this);
}

/// Extension for mapping DTO to domain entity (partial).
extension ExamSummaryMapper on ExamSummaryDto {
  AssignmentEntity toEntity({
    required String teacherId,
    String? description,
    required Difficulty difficulty,
    required int totalPoints,
    int? timeLimitMinutes,
  }) => AssignmentEntity(
    assignmentId: assignmentId,
    teacherId: teacherId,
    title: title,
    description: description,
    subject: Subject.fromApiValue(subject),
    gradeLevel: GradeLevel.fromApiValue(gradeLevel),
    totalQuestions: totalQuestions,
    totalPoints: totalPoints,
    timeLimitMinutes: timeLimitMinutes,
    createdAt: createdAt,
  );
}
