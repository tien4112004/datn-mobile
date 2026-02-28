import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_response_dto.g.dart';

/// DTO for assignment response (create/duplicate).
/// Based on ExamResponse schema from assignments.yaml API.
@JsonSerializable()
class AssignmentResponseDto {
  final String id;
  final String ownerId;
  final String title;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  AssignmentResponseDto({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.createdAt,
  });

  factory AssignmentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AssignmentResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentResponseDtoToJson(this);
}

/// Extension for mapping DTO to domain entity (partial).
extension AssignmentResponseMapper on AssignmentResponseDto {
  AssignmentEntity toEntity({
    String? description,
    required String subject,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int totalQuestions = 0,
    int totalPoints = 0,
  }) => AssignmentEntity(
    assignmentId: id,
    teacherId: ownerId,
    title: title,
    description: description,
    subject: Subject.fromApiValue(subject),
    gradeLevel: gradeLevel,
    totalQuestions: totalQuestions,
    totalPoints: totalPoints,
    createdAt: createdAt,
  );
}
