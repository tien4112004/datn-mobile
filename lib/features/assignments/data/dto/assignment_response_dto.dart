import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_response_dto.g.dart';

/// DTO for assignment response (create/duplicate).
/// Based on ExamResponse schema from assignments.yaml API.
@JsonSerializable()
class ExamResponseDto {
  @JsonKey(name: 'assignment_id')
  final String assignmentId;
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  final String title;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ExamResponseDto({
    required this.assignmentId,
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
  AssignmentEntity toEntity({
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int totalQuestions = 0,
    int totalPoints = 0,
  }) => AssignmentEntity(
    assignmentId: assignmentId,
    teacherId: teacherId,
    title: title,
    description: description,
    topic: topic,
    gradeLevel: gradeLevel,
    status: AssignmentStatus.fromName(status),
    difficulty: difficulty,
    totalQuestions: totalQuestions,
    totalPoints: totalPoints,
    createdAt: createdAt,
    shuffleQuestions: true,
  );
}
