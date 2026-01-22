import 'package:datn_mobile/features/assignments/data/dto/api/question_response.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_response.g.dart';

/// API-compliant DTO for assignment response.
/// Matches AssignmentResponse from ASSIGNMENT_API_DOCS.md
@JsonSerializable(fieldRename: FieldRename.none)
class AssignmentResponse {
  final String id;
  final String title;
  final String? description;
  final int? duration; // Minutes
  final String ownerId;
  final String subject;
  final String? grade;
  final List<QuestionResponse>? questions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AssignmentResponse({
    required this.id,
    required this.title,
    this.description,
    this.duration,
    required this.ownerId,
    required this.subject,
    this.grade,
    this.questions,
    required this.createdAt,
    this.updatedAt,
  });

  factory AssignmentResponse.fromJson(Map<String, dynamic> json) =>
      _$AssignmentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentResponseToJson(this);
}

/// Extension for mapping DTO to domain entity.
extension AssignmentResponseMapper on AssignmentResponse {
  AssignmentEntity toEntity() {
    // Map questions to domain entities
    final questionEntities = questions?.map((q) => q.toEntity()).toList() ?? [];

    // Calculate totals from questions if available
    final totalQuestions = questionEntities.length;
    final totalPoints = questionEntities.fold<double>(
      0,
      (sum, q) => sum + q.points,
    );

    // Infer grade level from grade string
    GradeLevel gradeLevel = GradeLevel.k;
    if (grade != null) {
      try {
        gradeLevel = GradeLevel.fromName(grade!.toLowerCase());
      } catch (_) {
        // Default to K if parsing fails
      }
    }

    // Parse subject from API string value
    Subject? parsedSubject;
    if (subject.isNotEmpty) {
      parsedSubject = Subject.fromApiValue(subject);
    }

    return AssignmentEntity(
      assignmentId: id,
      teacherId: ownerId,
      title: title,
      description: description,
      subject: parsedSubject ?? Subject.mathematics, // Default to mathematics
      gradeLevel: gradeLevel,
      status: AssignmentStatus.completed, // Default status
      difficulty: Difficulty.knowledge, // Default difficulty
      totalQuestions: totalQuestions,
      totalPoints: totalPoints.toInt(),
      timeLimitMinutes: duration,
      questionOrder: null, // TODO: Map from questions array
      shuffleQuestions: false,
      createdAt: createdAt,
      updatedAt: updatedAt,
      questions: questionEntities,
    );
  }
}
