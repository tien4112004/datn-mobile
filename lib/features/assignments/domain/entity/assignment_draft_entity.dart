import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';

/// Represents a gap in the matrix — questions that were requested but not found.
class MatrixGapEntity {
  final String topic;
  final String difficulty;
  final String questionType;
  final int requiredCount;
  final int availableCount;

  const MatrixGapEntity({
    required this.topic,
    required this.difficulty,
    required this.questionType,
    required this.requiredCount,
    required this.availableCount,
  });

  int get gapCount => requiredCount - availableCount;
}

/// Draft assignment returned by the AI generation endpoints.
class AssignmentDraftEntity {
  final String id;
  final String title;
  final String? description;
  final String subject;
  final String? grade;
  final List<AssignmentQuestionEntity> questions;
  final List<MatrixGapEntity> gaps;
  final double totalPoints;
  final int totalQuestions;
  final bool isComplete;

  const AssignmentDraftEntity({
    required this.id,
    required this.title,
    this.description,
    required this.subject,
    this.grade,
    required this.questions,
    required this.gaps,
    required this.totalPoints,
    required this.totalQuestions,
    required this.isComplete,
  });
}
