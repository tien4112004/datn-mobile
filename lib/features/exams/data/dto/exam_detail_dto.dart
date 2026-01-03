import 'package:datn_mobile/features/exams/data/dto/question_order_dto.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_entity.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_detail_dto.g.dart';

/// DTO for exam detail view.
/// Based on ExamDetail schema from exams.yaml API.
@JsonSerializable()
class ExamDetailDto {
  @JsonKey(name: 'exam_id')
  final String examId;
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  final String title;
  final String? description;
  final String topic;
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
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  ExamDetailDto({
    required this.examId,
    required this.teacherId,
    required this.title,
    this.description,
    required this.topic,
    required this.gradeLevel,
    required this.status,
    required this.difficulty,
    required this.totalQuestions,
    required this.totalPoints,
    this.timeLimitMinutes,
    this.questionOrder,
    required this.createdAt,
    this.updatedAt,
  });

  factory ExamDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ExamDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamDetailDtoToJson(this);
}

/// Extension for mapping DTO to domain entity.
extension ExamDetailMapper on ExamDetailDto {
  ExamEntity toEntity() => ExamEntity(
    examId: examId,
    teacherId: teacherId,
    title: title,
    description: description,
    topic: topic,
    gradeLevel: GradeLevel.fromString(gradeLevel),
    status: ExamStatus.fromString(status),
    difficulty: Difficulty.fromString(difficulty),
    totalQuestions: totalQuestions,
    totalPoints: totalPoints,
    timeLimitMinutes: timeLimitMinutes,
    questionOrder: questionOrder?.toEntity(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
