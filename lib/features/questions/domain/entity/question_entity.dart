import '../../../../shared/models/cms_enums.dart';

/// Base question entity
abstract class BaseQuestion {
  final String id;
  final QuestionType type;
  final Difficulty difficulty;
  final String title;
  final String? titleImageUrl;
  final String? explanation;

  const BaseQuestion({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.title,
    this.titleImageUrl,
    this.explanation,
  });
}

/// Multiple Choice Question
class MultipleChoiceQuestion extends BaseQuestion {
  final MultipleChoiceData data;

  const MultipleChoiceQuestion({
    required super.id,
    required super.difficulty,
    required super.title,
    super.titleImageUrl,
    super.explanation,
    required this.data,
  }) : super(type: QuestionType.multipleChoice);

  MultipleChoiceQuestion copyWith({
    String? id,
    Difficulty? difficulty,
    String? title,
    String? titleImageUrl,
    String? explanation,
    MultipleChoiceData? data,
  }) {
    return MultipleChoiceQuestion(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      title: title ?? this.title,
      titleImageUrl: titleImageUrl ?? this.titleImageUrl,
      explanation: explanation ?? this.explanation,
      data: data ?? this.data,
    );
  }
}

/// Matching Question
class MatchingQuestion extends BaseQuestion {
  final MatchingData data;

  const MatchingQuestion({
    required super.id,
    required super.difficulty,
    required super.title,
    super.titleImageUrl,
    super.explanation,
    required this.data,
  }) : super(type: QuestionType.matching);

  MatchingQuestion copyWith({
    String? id,
    Difficulty? difficulty,
    String? title,
    String? titleImageUrl,
    String? explanation,
    MatchingData? data,
  }) {
    return MatchingQuestion(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      title: title ?? this.title,
      titleImageUrl: titleImageUrl ?? this.titleImageUrl,
      explanation: explanation ?? this.explanation,
      data: data ?? this.data,
    );
  }
}

/// Open Ended Question
class OpenEndedQuestion extends BaseQuestion {
  final OpenEndedData data;

  const OpenEndedQuestion({
    required super.id,
    required super.difficulty,
    required super.title,
    super.titleImageUrl,
    super.explanation,
    required this.data,
  }) : super(type: QuestionType.openEnded);

  OpenEndedQuestion copyWith({
    String? id,
    Difficulty? difficulty,
    String? title,
    String? titleImageUrl,
    String? explanation,
    OpenEndedData? data,
  }) {
    return OpenEndedQuestion(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      title: title ?? this.title,
      titleImageUrl: titleImageUrl ?? this.titleImageUrl,
      explanation: explanation ?? this.explanation,
      data: data ?? this.data,
    );
  }
}

/// Fill in Blank Question
class FillInBlankQuestion extends BaseQuestion {
  final FillInBlankData data;

  const FillInBlankQuestion({
    required super.id,
    required super.difficulty,
    required super.title,
    super.titleImageUrl,
    super.explanation,
    required this.data,
  }) : super(type: QuestionType.fillInBlank);

  FillInBlankQuestion copyWith({
    String? id,
    Difficulty? difficulty,
    String? title,
    String? titleImageUrl,
    String? explanation,
    FillInBlankData? data,
  }) {
    return FillInBlankQuestion(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      title: title ?? this.title,
      titleImageUrl: titleImageUrl ?? this.titleImageUrl,
      explanation: explanation ?? this.explanation,
      data: data ?? this.data,
    );
  }
}

/// Multiple Choice Option
class MultipleChoiceOption {
  final String id;
  final String text;
  final String? imageUrl;
  final bool isCorrect;

  const MultipleChoiceOption({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.isCorrect,
  });

  MultipleChoiceOption copyWith({
    String? id,
    String? text,
    String? imageUrl,
    bool? isCorrect,
  }) {
    return MultipleChoiceOption(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

/// Multiple Choice Data
class MultipleChoiceData {
  final List<MultipleChoiceOption> options;
  final bool shuffleOptions;

  const MultipleChoiceData({
    required this.options,
    this.shuffleOptions = false,
  });

  MultipleChoiceData copyWith({
    List<MultipleChoiceOption>? options,
    bool? shuffleOptions,
  }) {
    return MultipleChoiceData(
      options: options ?? this.options,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
    );
  }
}

/// Matching Pair
class MatchingPair {
  final String id;
  final String? left;
  final String? leftImageUrl;
  final String? right;
  final String? rightImageUrl;

  const MatchingPair({
    required this.id,
    required this.left,
    this.leftImageUrl,
    required this.right,
    this.rightImageUrl,
  });

  MatchingPair copyWith({
    String? id,
    String? left,
    String? leftImageUrl,
    String? right,
    String? rightImageUrl,
  }) {
    return MatchingPair(
      id: id ?? this.id,
      left: left ?? this.left,
      leftImageUrl: leftImageUrl ?? this.leftImageUrl,
      right: right ?? this.right,
      rightImageUrl: rightImageUrl ?? this.rightImageUrl,
    );
  }
}

/// Matching Data
class MatchingData {
  final List<MatchingPair> pairs;
  final bool shufflePairs;

  const MatchingData({required this.pairs, this.shufflePairs = false});

  MatchingData copyWith({List<MatchingPair>? pairs, bool? shufflePairs}) {
    return MatchingData(
      pairs: pairs ?? this.pairs,
      shufflePairs: shufflePairs ?? this.shufflePairs,
    );
  }
}

/// Open Ended Data
class OpenEndedData {
  final String? expectedAnswer;
  final int? maxLength;

  const OpenEndedData({this.expectedAnswer, this.maxLength});

  OpenEndedData copyWith({String? expectedAnswer, int? maxLength}) {
    return OpenEndedData(
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      maxLength: maxLength ?? this.maxLength,
    );
  }
}

/// Blank Segment
class BlankSegment {
  final String id;
  final SegmentType type;
  final String content;
  final List<String>? acceptableAnswers;

  const BlankSegment({
    required this.id,
    required this.type,
    required this.content,
    this.acceptableAnswers,
  });

  BlankSegment copyWith({
    String? id,
    SegmentType? type,
    String? content,
    List<String>? acceptableAnswers,
  }) {
    return BlankSegment(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      acceptableAnswers: acceptableAnswers ?? this.acceptableAnswers,
    );
  }
}

enum SegmentType { text, blank }

/// Fill in Blank Data
class FillInBlankData {
  final List<BlankSegment> segments;
  final bool caseSensitive;

  const FillInBlankData({required this.segments, this.caseSensitive = false});

  FillInBlankData copyWith({
    List<BlankSegment>? segments,
    bool? caseSensitive,
  }) {
    return FillInBlankData(
      segments: segments ?? this.segments,
      caseSensitive: caseSensitive ?? this.caseSensitive,
    );
  }
}
