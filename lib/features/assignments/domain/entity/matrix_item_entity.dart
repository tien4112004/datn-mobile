import 'package:AIPrimary/shared/models/cms_enums.dart';

/// Domain entity for exam matrix item.
/// Represents a specification for generating a group of questions.
class MatrixItemEntity {
  final String topic;
  final QuestionType questionType;
  final int count;
  final int pointsEach;
  final Difficulty difficulty;
  final bool requiresContext;
  final ContextType? contextType;

  const MatrixItemEntity({
    required this.topic,
    required this.questionType,
    required this.count,
    required this.pointsEach,
    required this.difficulty,
    required this.requiresContext,
    this.contextType,
  });

  /// Calculate total points for this matrix item.
  int get totalPoints => count * pointsEach;

  MatrixItemEntity copyWith({
    String? topic,
    QuestionType? questionType,
    int? count,
    int? pointsEach,
    Difficulty? difficulty,
    bool? requiresContext,
    ContextType? contextType,
  }) {
    return MatrixItemEntity(
      topic: topic ?? this.topic,
      questionType: questionType ?? this.questionType,
      count: count ?? this.count,
      pointsEach: pointsEach ?? this.pointsEach,
      difficulty: difficulty ?? this.difficulty,
      requiresContext: requiresContext ?? this.requiresContext,
      contextType: contextType ?? this.contextType,
    );
  }
}
