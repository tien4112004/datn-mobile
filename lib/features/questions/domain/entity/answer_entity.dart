import '../../../../shared/models/cms_enums.dart';

/// Base answer entity for all question types
abstract class QuestionAnswer {
  final String questionId;
  final QuestionType type;

  const QuestionAnswer({required this.questionId, required this.type});
}

/// Multiple Choice answer — stores selected option ID
class MultipleChoiceAnswer extends QuestionAnswer {
  final String? selectedOptionId;

  const MultipleChoiceAnswer({required super.questionId, this.selectedOptionId})
    : super(type: QuestionType.multipleChoice);

  MultipleChoiceAnswer copyWith({String? selectedOptionId}) {
    return MultipleChoiceAnswer(
      questionId: questionId,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
    );
  }
}

/// Matching answer — maps leftId to rightId
class MatchingAnswer extends QuestionAnswer {
  final Map<String, String> matches;

  const MatchingAnswer({required super.questionId, this.matches = const {}})
    : super(type: QuestionType.matching);

  MatchingAnswer copyWith({Map<String, String>? matches}) {
    return MatchingAnswer(
      questionId: questionId,
      matches: matches ?? this.matches,
    );
  }
}

/// Fill in Blank answer — maps segmentId to filled value
class FillInBlankAnswer extends QuestionAnswer {
  final Map<String, String> blanks;

  const FillInBlankAnswer({required super.questionId, this.blanks = const {}})
    : super(type: QuestionType.fillInBlank);

  FillInBlankAnswer copyWith({Map<String, String>? blanks}) {
    return FillInBlankAnswer(
      questionId: questionId,
      blanks: blanks ?? this.blanks,
    );
  }
}

/// Open Ended answer — stores free text response
class OpenEndedAnswer extends QuestionAnswer {
  final String? text;

  const OpenEndedAnswer({required super.questionId, this.text})
    : super(type: QuestionType.openEnded);

  OpenEndedAnswer copyWith({String? text}) {
    return OpenEndedAnswer(questionId: questionId, text: text ?? this.text);
  }
}
