import 'package:datn_mobile/features/assignments/data/dto/question_order_dto.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_detail_dto.g.dart';

/// DTO for assignment detail view.
/// Based on ExamDetail schema from assignments.yaml API.
@JsonSerializable()
class AssignmentDetailDto {
  @JsonKey(name: 'assignment_id')
  final String assignmentId;
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  final String title;
  final String? description;
  final String subject;
  @JsonKey(name: 'grade_level')
  final String gradeLevel;
  final String status;
  final String difficulty;
  @JsonKey(name: 'total_questions')
  final int totalQuestions;
  @JsonKey(name: 'total_points')
  final int totalPoints;
  @JsonKey(name: 'time_limit_minutes')
  final int? timeLimitMinutes;
  @JsonKey(name: 'question_order')
  final QuestionOrderDto? questionOrder;
  @JsonKey(name: 'shuffle_questions', defaultValue: false)
  final bool shuffleQuestions;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  AssignmentDetailDto({
    required this.assignmentId,
    required this.teacherId,
    required this.title,
    this.description,
    required this.subject,
    required this.gradeLevel,
    required this.status,
    required this.difficulty,
    required this.totalQuestions,
    required this.totalPoints,
    this.timeLimitMinutes,
    this.questionOrder,
    this.shuffleQuestions = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory AssignmentDetailDto.fromJson(Map<String, dynamic> json) =>
      _$AssignmentDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentDetailDtoToJson(this);
}

/// Extension for mapping DTO to domain entity.
extension AssignmentDetailMapper on AssignmentDetailDto {
  AssignmentEntity toEntity() => AssignmentEntity(
    assignmentId: assignmentId,
    teacherId: teacherId,
    title: title,
    description: description,
    subject: Subject.fromApiValue(subject),
    gradeLevel: GradeLevel.fromName(gradeLevel),
    status: AssignmentStatus.fromName(status),
    difficulty: Difficulty.fromName(difficulty),
    totalQuestions: totalQuestions,
    totalPoints: totalPoints,
    timeLimitMinutes: timeLimitMinutes,
    questionOrder: questionOrder?.toEntity(),
    shuffleQuestions: shuffleQuestions,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
