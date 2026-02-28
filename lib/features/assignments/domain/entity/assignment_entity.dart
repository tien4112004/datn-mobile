import 'package:AIPrimary/features/assignments/domain/entity/api_matrix_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

/// Domain entity for an exam.
/// Pure business object without JSON annotations.
class AssignmentEntity {
  final String assignmentId;
  final String teacherId;
  final String title;
  final String? description;
  final Subject subject;
  final GradeLevel gradeLevel;
  final int totalQuestions;
  final int totalPoints;
  final int? timeLimitMinutes;
  final QuestionOrder? questionOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Questions in this assignment with point values
  final List<AssignmentQuestionEntity> questions;

  /// Contexts (reading passages) embedded in this assignment
  final List<ContextEntity> contexts;

  /// Matrix specification (topic × difficulty × questionType) from API
  final ApiMatrixEntity? matrix;

  const AssignmentEntity({
    required this.assignmentId,
    required this.teacherId,
    required this.title,
    this.description,
    required this.subject,
    required this.gradeLevel,
    required this.totalQuestions,
    required this.totalPoints,
    this.createdAt,
    this.timeLimitMinutes,
    this.questionOrder,
    this.updatedAt,
    this.questions = const [],
    this.contexts = const [],
    this.matrix,
  });

  AssignmentEntity copyWith({
    String? assignmentId,
    String? teacherId,
    String? title,
    String? description,
    Subject? subject,
    GradeLevel? gradeLevel,
    int? totalQuestions,
    int? totalPoints,
    int? timeLimitMinutes,
    QuestionOrder? questionOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AssignmentQuestionEntity>? questions,
    List<ContextEntity>? contexts,
    ApiMatrixEntity? matrix,
  }) {
    return AssignmentEntity(
      assignmentId: assignmentId ?? this.assignmentId,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPoints: totalPoints ?? this.totalPoints,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      questionOrder: questionOrder ?? this.questionOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      questions: questions ?? this.questions,
      contexts: contexts ?? this.contexts,
      matrix: matrix ?? this.matrix,
    );
  }
}

/// Question order structure.
class QuestionOrder {
  final List<QuestionOrderItemBase> items;

  const QuestionOrder({required this.items});

  QuestionOrder copyWith({List<QuestionOrderItemBase>? items}) {
    return QuestionOrder(items: items ?? this.items);
  }
}

/// Base class for question order items.
abstract class QuestionOrderItemBase {
  const QuestionOrderItemBase();
}

/// Single question order item.
class QuestionOrderItem extends QuestionOrderItemBase {
  final String questionId;
  final int points;

  const QuestionOrderItem({required this.questionId, required this.points});
}

/// Context group order item (for questions with shared context).
class ContextGroupOrderItem extends QuestionOrderItemBase {
  final String contextId;
  final List<ContextQuestion> questions;

  const ContextGroupOrderItem({
    required this.contextId,
    required this.questions,
  });
}

/// Question within a context group.
class ContextQuestion {
  final String questionId;
  final int points;

  const ContextQuestion({required this.questionId, required this.points});
}
