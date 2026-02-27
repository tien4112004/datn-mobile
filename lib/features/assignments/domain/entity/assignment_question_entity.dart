import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/question_item_request.dart';

/// Domain entity representing a question within an assignment context.
///
/// This entity wraps a [BaseQuestion] with assignment-specific metadata:
/// - Points assigned for this question in this assignment
/// - Origin tracking (created directly vs selected from bank)
/// - Optional question bank ID for tracking source
/// - Optional context ID for questions with reading passages
class AssignmentQuestionEntity {
  /// Question bank ID if from bank, null if created directly
  final String? questionBankId;

  /// The actual question content (polymorphic)
  final BaseQuestion question;

  /// Points assigned for this question in this assignment
  final double points;

  /// Whether this question was created directly in assignment (true)
  /// or selected from question bank (false)
  final bool isNewQuestion;

  /// Context ID for questions with reading passage, null if standalone
  final String? contextId;

  /// Topic ID this question belongs to (from API `chapter` field).
  /// Questions are now bound directly to topics (not subtopics).
  /// Used to compute per-cell actual counts in the matrix.
  final String? topicId;

  const AssignmentQuestionEntity({
    this.questionBankId,
    required this.question,
    required this.points,
    required this.isNewQuestion,
    this.contextId,
    this.topicId,
  });

  /// Create a copy with updated fields.
  ///
  /// Pass [clearContextId] = true to explicitly set contextId to null.
  /// This is needed because the standard `contextId` parameter can't
  /// distinguish between "not provided" and "set to null".
  AssignmentQuestionEntity copyWith({
    String? questionBankId,
    BaseQuestion? question,
    double? points,
    bool? isNewQuestion,
    String? contextId,
    bool clearContextId = false,
    String? topicId,
  }) {
    return AssignmentQuestionEntity(
      questionBankId: questionBankId ?? this.questionBankId,
      question: question ?? this.question,
      points: points ?? this.points,
      isNewQuestion: isNewQuestion ?? this.isNewQuestion,
      contextId: clearContextId ? null : (contextId ?? this.contextId),
      topicId: topicId ?? this.topicId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssignmentQuestionEntity &&
        other.questionBankId == questionBankId &&
        other.question == question &&
        other.points == points &&
        other.isNewQuestion == isNewQuestion &&
        other.contextId == contextId &&
        other.topicId == topicId;
  }

  @override
  int get hashCode {
    return Object.hash(
      questionBankId,
      question,
      points,
      isNewQuestion,
      contextId,
      topicId,
    );
  }

  @override
  String toString() {
    return 'AssignmentQuestionEntity(questionBankId: $questionBankId, '
        'question: ${question.title}, points: $points, isNewQuestion: $isNewQuestion, '
        'contextId: $contextId, topicId: $topicId)';
  }
}

/// Extension to convert AssignmentQuestionEntity to API request format
extension AssignmentQuestionMapper on AssignmentQuestionEntity {
  /// Convert to QuestionItemRequest for API submission
  QuestionItemRequest toRequest() {
    return QuestionItemRequest(
      id: isNewQuestion ? null : questionBankId,
      type: question.type.apiValue,
      difficulty: question.difficulty.apiValue,
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      explanation: question.explanation,
      chapter: topicId,
      contextId: contextId,
      point: points,
      data: _questionToDataMap(question),
    );
  }

  /// Convert BaseQuestion to Map based on type
  static Map<String, dynamic> _questionToDataMap(BaseQuestion question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        final mcQuestion = question as MultipleChoiceQuestion;
        return {
          'type': question
              .type
              .apiValue, // Required by backend for polymorphic deserialization
          'options': mcQuestion.data.options
              .map(
                (opt) => {
                  'text': opt.text,
                  'imageUrl': opt.imageUrl,
                  'isCorrect': opt.isCorrect,
                },
              )
              .toList(),
          'shuffleOptions': mcQuestion.data.shuffleOptions,
        };

      case QuestionType.matching:
        final matchingQuestion = question as MatchingQuestion;
        return {
          'type': question
              .type
              .apiValue, // Required by backend for polymorphic deserialization
          'pairs': matchingQuestion.data.pairs
              .map(
                (pair) => {
                  'left': pair.left,
                  'leftImageUrl': pair.leftImageUrl,
                  'right': pair.right,
                  'rightImageUrl': pair.rightImageUrl,
                },
              )
              .toList(),
          'shufflePairs': matchingQuestion.data.shufflePairs,
        };

      case QuestionType.openEnded:
        final openEndedQuestion = question as OpenEndedQuestion;
        return {
          'type': question
              .type
              .apiValue, // Required by backend for polymorphic deserialization
          'expectedAnswer': openEndedQuestion.data.expectedAnswer,
          'maxLength': openEndedQuestion.data.maxLength,
        };

      case QuestionType.fillInBlank:
        final fillInBlankQuestion = question as FillInBlankQuestion;
        return {
          'type': question
              .type
              .apiValue, // Required by backend for polymorphic deserialization
          'segments': fillInBlankQuestion.data.segments
              .map(
                (seg) => {
                  'type': seg.type == SegmentType.text ? 'TEXT' : 'BLANK',
                  'content': seg.content,
                  'acceptableAnswers': seg.acceptableAnswers,
                },
              )
              .toList(),
          'caseSensitive': fillInBlankQuestion.data.caseSensitive,
        };
    }
  }
}
