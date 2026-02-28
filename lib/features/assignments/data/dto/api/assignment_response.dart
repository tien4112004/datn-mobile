import 'package:AIPrimary/features/assignments/data/dto/api/api_matrix_dto.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/context_response.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/question_response.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
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
  final List<ContextResponse>? contexts;
  final ApiMatrixDto? matrix;
  final DateTime? createdAt;
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
    this.contexts,
    this.matrix,
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

    // Map contexts to domain entities
    final contextEntities = contexts?.map((c) => c.toEntity()).toList() ?? [];

    // Calculate totals from questions if available
    final totalQuestions = questionEntities.length;
    final totalPoints = questionEntities.fold<double>(
      0,
      (sum, q) => sum + q.points,
    );

    // Infer grade level from grade string
    GradeLevel gradeLevel = GradeLevel.grade1;
    if (grade != null) {
      try {
        gradeLevel = GradeLevel.fromApiValue(grade!.toLowerCase());
      } catch (_) {
        // Default to K if parsing fails
      }
    }

    // Parse subject from API string value
    Subject? parsedSubject;
    if (subject.isNotEmpty) {
      parsedSubject = Subject.fromApiValue(subject);
    }

    // Build questionOrder from questions array.
    // Group questions with contextId into ContextGroupOrderItem,
    // standalone questions become QuestionOrderItem.
    QuestionOrder? questionOrder;
    if (questionEntities.isNotEmpty) {
      final orderItems = <QuestionOrderItemBase>[];
      final processedContextIds = <String>{};

      for (int i = 0; i < questionEntities.length; i++) {
        final qEntity = questionEntities[i];
        final contextId = qEntity.contextId;

        if (contextId != null && contextId.isNotEmpty) {
          // Context question — group all with same contextId
          if (processedContextIds.contains(contextId)) continue;
          processedContextIds.add(contextId);

          final contextQuestions = questionEntities
              .where((q) => q.contextId == contextId)
              .map(
                (q) => ContextQuestion(
                  questionId: q.question.id,
                  points: q.points.toInt(),
                ),
              )
              .toList();

          orderItems.add(
            ContextGroupOrderItem(
              contextId: contextId,
              questions: contextQuestions,
            ),
          );
        } else {
          // Standalone question
          orderItems.add(
            QuestionOrderItem(
              questionId: qEntity.question.id,
              points: qEntity.points.toInt(),
            ),
          );
        }
      }

      questionOrder = QuestionOrder(items: orderItems);
    }

    return AssignmentEntity(
      assignmentId: id,
      teacherId: ownerId,
      title: title,
      description: description,
      subject: parsedSubject ?? Subject.mathematics, // Default to mathematics
      gradeLevel: gradeLevel,
      totalQuestions: totalQuestions,
      totalPoints: totalPoints.toInt(),
      timeLimitMinutes: duration,
      questionOrder: questionOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      questions: questionEntities,
      contexts: contextEntities,
      matrix: matrix?.toEntity(),
    );
  }
}
