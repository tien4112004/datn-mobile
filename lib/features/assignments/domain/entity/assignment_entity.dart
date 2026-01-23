import 'package:datn_mobile/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';

/// Domain entity for an exam.
/// Pure business object without JSON annotations.
class AssignmentEntity {
  final String assignmentId;
  final String teacherId;
  final String title;
  final String? description;
  final Subject subject;
  final GradeLevel gradeLevel;
  final AssignmentStatus status;
  final int totalQuestions;
  final int totalPoints;
  final int? timeLimitMinutes;
  final QuestionOrder? questionOrder;
  final bool shuffleQuestions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Questions in this assignment with point values
  final List<AssignmentQuestionEntity> questions;

  const AssignmentEntity({
    required this.assignmentId,
    required this.teacherId,
    required this.title,
    this.description,
    required this.subject,
    required this.gradeLevel,
    required this.status,
    required this.totalQuestions,
    required this.totalPoints,
    required this.shuffleQuestions,
    required this.createdAt,
    this.timeLimitMinutes,
    this.questionOrder,
    this.updatedAt,
    this.questions = const [],
  });

  /// Check if the exam is editable (draft or error status).
  bool get isEditable =>
      status == AssignmentStatus.draft || status == AssignmentStatus.error;

  /// Check if the exam can be deleted.
  bool get isDeletable => status == AssignmentStatus.draft;

  /// Check if the exam is ready for use.
  bool get isReady => status == AssignmentStatus.completed;

  AssignmentEntity copyWith({
    String? assignmentId,
    String? teacherId,
    String? title,
    String? description,
    Subject? subject,
    GradeLevel? gradeLevel,
    AssignmentStatus? status,
    int? totalQuestions,
    int? totalPoints,
    int? timeLimitMinutes,
    QuestionOrder? questionOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? shuffleQuestions,
    List<AssignmentQuestionEntity>? questions,
  }) {
    return AssignmentEntity(
      assignmentId: assignmentId ?? this.assignmentId,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      status: status ?? this.status,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPoints: totalPoints ?? this.totalPoints,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      questionOrder: questionOrder ?? this.questionOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      questions: questions ?? this.questions,
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
