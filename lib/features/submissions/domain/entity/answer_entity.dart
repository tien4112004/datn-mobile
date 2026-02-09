import 'package:AIPrimary/features/submissions/domain/entity/grade_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

/// Base answer entity for polymorphic answer types
abstract class AnswerEntity {
  final String questionId;
  final QuestionType type;
  final GradeEntity? grade;

  const AnswerEntity({
    required this.questionId,
    required this.type,
    this.grade,
  });

  /// Check if this answer has been filled/answered
  bool get isAnswered;

  /// Create a copy with updated grade
  AnswerEntity withGrade(GradeEntity? grade);
}

/// Multiple Choice Answer Entity
class MultipleChoiceAnswerEntity extends AnswerEntity {
  final String? selectedOptionId;

  const MultipleChoiceAnswerEntity({
    required super.questionId,
    this.selectedOptionId,
    super.grade,
  }) : super(type: QuestionType.multipleChoice);

  @override
  bool get isAnswered =>
      selectedOptionId != null && selectedOptionId!.isNotEmpty;

  @override
  MultipleChoiceAnswerEntity withGrade(GradeEntity? grade) {
    return MultipleChoiceAnswerEntity(
      questionId: questionId,
      selectedOptionId: selectedOptionId,
      grade: grade,
    );
  }

  MultipleChoiceAnswerEntity copyWith({
    String? questionId,
    String? selectedOptionId,
    GradeEntity? grade,
  }) {
    return MultipleChoiceAnswerEntity(
      questionId: questionId ?? this.questionId,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      grade: grade ?? this.grade,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultipleChoiceAnswerEntity &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          selectedOptionId == other.selectedOptionId;

  @override
  int get hashCode => Object.hash(questionId, selectedOptionId);

  @override
  String toString() =>
      'MultipleChoiceAnswerEntity(questionId: $questionId, selectedOptionId: $selectedOptionId)';
}

/// Fill in Blank Answer Entity
class FillInBlankAnswerEntity extends AnswerEntity {
  /// Map of blank ID to student's answer
  final Map<String, String> blankAnswers;

  const FillInBlankAnswerEntity({
    required super.questionId,
    required this.blankAnswers,
    super.grade,
  }) : super(type: QuestionType.fillInBlank);

  @override
  bool get isAnswered =>
      blankAnswers.isNotEmpty &&
      blankAnswers.values.every((answer) => answer.isNotEmpty);

  @override
  FillInBlankAnswerEntity withGrade(GradeEntity? grade) {
    return FillInBlankAnswerEntity(
      questionId: questionId,
      blankAnswers: blankAnswers,
      grade: grade,
    );
  }

  FillInBlankAnswerEntity copyWith({
    String? questionId,
    Map<String, String>? blankAnswers,
    GradeEntity? grade,
  }) {
    return FillInBlankAnswerEntity(
      questionId: questionId ?? this.questionId,
      blankAnswers: blankAnswers ?? this.blankAnswers,
      grade: grade ?? this.grade,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FillInBlankAnswerEntity &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          _mapEquals(blankAnswers, other.blankAnswers);

  @override
  int get hashCode => Object.hash(questionId, blankAnswers);

  @override
  String toString() =>
      'FillInBlankAnswerEntity(questionId: $questionId, blanks: ${blankAnswers.length})';
}

/// Matching Answer Entity
class MatchingAnswerEntity extends AnswerEntity {
  /// Map of left item ID to right item ID
  final Map<String, String> matchedPairs;

  const MatchingAnswerEntity({
    required super.questionId,
    required this.matchedPairs,
    super.grade,
  }) : super(type: QuestionType.matching);

  @override
  bool get isAnswered => matchedPairs.isNotEmpty;

  @override
  MatchingAnswerEntity withGrade(GradeEntity? grade) {
    return MatchingAnswerEntity(
      questionId: questionId,
      matchedPairs: matchedPairs,
      grade: grade,
    );
  }

  MatchingAnswerEntity copyWith({
    String? questionId,
    Map<String, String>? matchedPairs,
    GradeEntity? grade,
  }) {
    return MatchingAnswerEntity(
      questionId: questionId ?? this.questionId,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      grade: grade ?? this.grade,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchingAnswerEntity &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          _mapEquals(matchedPairs, other.matchedPairs);

  @override
  int get hashCode => Object.hash(questionId, matchedPairs);

  @override
  String toString() =>
      'MatchingAnswerEntity(questionId: $questionId, pairs: ${matchedPairs.length})';
}

/// Open-Ended Answer Entity
class OpenEndedAnswerEntity extends AnswerEntity {
  final String? response;

  const OpenEndedAnswerEntity({
    required super.questionId,
    this.response,
    super.grade,
  }) : super(type: QuestionType.openEnded);

  @override
  bool get isAnswered => response != null && response!.trim().isNotEmpty;

  @override
  OpenEndedAnswerEntity withGrade(GradeEntity? grade) {
    return OpenEndedAnswerEntity(
      questionId: questionId,
      response: response,
      grade: grade,
    );
  }

  OpenEndedAnswerEntity copyWith({
    String? questionId,
    String? response,
    GradeEntity? grade,
  }) {
    return OpenEndedAnswerEntity(
      questionId: questionId ?? this.questionId,
      response: response ?? this.response,
      grade: grade ?? this.grade,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenEndedAnswerEntity &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          response == other.response;

  @override
  int get hashCode => Object.hash(questionId, response);

  @override
  String toString() =>
      'OpenEndedAnswerEntity(questionId: $questionId, response: ${response?.substring(0, response!.length > 50 ? 50 : response!.length)}...)';
}

/// Helper function to compare maps for equality
bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}
