part of 'controller_provider.dart';

/// State for answer collection during assignment
class AnswerCollectionState {
  final Map<String, AnswerEntity> answers;
  final AssignmentEntity assignment;

  const AnswerCollectionState({
    required this.answers,
    required this.assignment,
  });

  /// Count of answered questions
  int get answeredCount => answers.values.where((a) => a.isAnswered).length;

  /// Total question count
  int get totalQuestions => assignment.questions.length;

  /// Progress percentage (0-100)
  double get progress =>
      totalQuestions > 0 ? (answeredCount / totalQuestions) * 100 : 0;

  /// Check if all questions are answered
  bool get isComplete => answeredCount == totalQuestions;

  AnswerCollectionState copyWith({
    Map<String, AnswerEntity>? answers,
    AssignmentEntity? assignment,
  }) {
    return AnswerCollectionState(
      answers: answers ?? this.answers,
      assignment: assignment ?? this.assignment,
    );
  }
}

/// Controller for managing answer collection during assignment taking
class AnswerCollectionController extends StateNotifier<AnswerCollectionState> {
  AnswerCollectionController(AssignmentEntity assignment)
    : super(AnswerCollectionState(answers: {}, assignment: assignment)) {
    _initializeAnswers();
  }

  /// Initialize empty answers for all questions
  void _initializeAnswers() {
    final Map<String, AnswerEntity> initialAnswers = {};

    for (final assignmentQuestion in state.assignment.questions) {
      final question = assignmentQuestion.question;

      switch (question.type) {
        case QuestionType.multipleChoice:
          initialAnswers[question.id] = MultipleChoiceAnswerEntity(
            questionId: question.id,
          );
          break;

        case QuestionType.fillInBlank:
          initialAnswers[question.id] = FillInBlankAnswerEntity(
            questionId: question.id,
            blankAnswers: {},
          );
          break;

        case QuestionType.matching:
          initialAnswers[question.id] = MatchingAnswerEntity(
            questionId: question.id,
            matchedPairs: {},
          );
          break;

        case QuestionType.openEnded:
          initialAnswers[question.id] = OpenEndedAnswerEntity(
            questionId: question.id,
          );
          break;
      }
    }

    state = state.copyWith(answers: initialAnswers);
  }

  /// Update answer for a specific question
  void updateAnswer(AnswerEntity answer) {
    final updatedAnswers = Map<String, AnswerEntity>.from(state.answers);
    updatedAnswers[answer.questionId] = answer;
    state = state.copyWith(answers: updatedAnswers);
  }

  /// Remove answer for a specific question (reset to empty)
  void removeAnswer(String questionId) {
    final questionEntity = state.assignment.questions
        .firstWhere((q) => q.question.id == questionId)
        .question;

    AnswerEntity emptyAnswer;

    switch (questionEntity.type) {
      case QuestionType.multipleChoice:
        emptyAnswer = MultipleChoiceAnswerEntity(questionId: questionId);
        break;
      case QuestionType.fillInBlank:
        emptyAnswer = FillInBlankAnswerEntity(
          questionId: questionId,
          blankAnswers: {},
        );
        break;
      case QuestionType.matching:
        emptyAnswer = MatchingAnswerEntity(
          questionId: questionId,
          matchedPairs: {},
        );
        break;
      case QuestionType.openEnded:
        emptyAnswer = OpenEndedAnswerEntity(questionId: questionId);
        break;
    }

    updateAnswer(emptyAnswer);
  }

  /// Get answers ready for submission (only answered questions)
  List<AnswerEntity> getAnswersForSubmission() {
    return state.answers.values.toList();
  }

  /// Validate that all questions are answered
  /// Returns list of unanswered question indices
  List<int> validateAnswers() {
    final unanswered = <int>[];

    for (var i = 0; i < state.assignment.questions.length; i++) {
      final questionId = state.assignment.questions[i].question.id;
      final answer = state.answers[questionId];

      if (answer == null || !answer.isAnswered) {
        unanswered.add(i);
      }
    }

    return unanswered;
  }

  /// Clear all answers
  void clearAll() {
    _initializeAnswers();
  }
}
