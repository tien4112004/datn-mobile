import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';

/// Domain entity for an exam.
/// Pure business object without JSON annotations.
class ExamEntity {
  final String examId;
  final String teacherId;
  final String title;
  final String? description;
  final String topic;
  final GradeLevel gradeLevel;
  final ExamStatus status;
  final Difficulty difficulty;
  final int totalQuestions;
  final int totalPoints;
  final int? timeLimitMinutes;
  final QuestionOrder? questionOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ExamEntity({
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

  /// Check if the exam is editable (draft or error status).
  bool get isEditable =>
      status == ExamStatus.draft || status == ExamStatus.error;

  /// Check if the exam can be deleted.
  bool get isDeletable => status == ExamStatus.draft;

  /// Check if the exam is ready for use.
  bool get isReady => status == ExamStatus.completed;

  ExamEntity copyWith({
    String? examId,
    String? teacherId,
    String? title,
    String? description,
    String? topic,
    GradeLevel? gradeLevel,
    ExamStatus? status,
    Difficulty? difficulty,
    int? totalQuestions,
    int? totalPoints,
    int? timeLimitMinutes,
    QuestionOrder? questionOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamEntity(
      examId: examId ?? this.examId,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      description: description ?? this.description,
      topic: topic ?? this.topic,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPoints: totalPoints ?? this.totalPoints,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      questionOrder: questionOrder ?? this.questionOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
