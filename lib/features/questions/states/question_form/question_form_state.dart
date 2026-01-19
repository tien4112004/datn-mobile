import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/fill_in_blank_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/matching_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/multiple_choice_section.dart';

/// State for question form (create/edit)
class QuestionFormState {
  // Question ID (null for create, non-null for edit)
  final String? questionId;

  // Basic information
  final String title;
  final QuestionType type;
  final Difficulty difficulty;
  final String? titleImageUrl;
  final int points;
  final String explanation;
  final Grade grade;
  final String? chapter;
  final Subject subject;

  // Multiple Choice specific
  final List<MultipleChoiceOptionData> multipleChoiceOptions;
  final bool shuffleOptions;

  // Matching specific
  final List<MatchingPairData> matchingPairs;
  final bool shufflePairs;

  // Open Ended specific
  final String? expectedAnswer;
  final int? maxLength;

  // Fill in Blank specific
  final List<SegmentData> segments;
  final bool caseSensitive;

  // Form state
  final bool hasUnsavedChanges;
  final bool isLoading;

  const QuestionFormState({
    this.questionId,
    this.title = '',
    this.type = QuestionType.multipleChoice,
    this.difficulty = Difficulty.knowledge,
    this.titleImageUrl,
    this.points = 0,
    this.explanation = '',
    this.grade = Grade.grade1,
    this.chapter,
    this.subject = Subject.english,
    this.multipleChoiceOptions = const [],
    this.shuffleOptions = false,
    this.matchingPairs = const [],
    this.shufflePairs = false,
    this.expectedAnswer,
    this.maxLength,
    this.segments = const [],
    this.caseSensitive = false,
    this.hasUnsavedChanges = false,
    this.isLoading = false,
  });

  /// Check if this is an edit operation
  bool get isEditing => questionId != null;

  /// Create a copy with updated fields
  QuestionFormState copyWith({
    String? questionId,
    String? title,
    QuestionType? type,
    Difficulty? difficulty,
    String? titleImageUrl,
    int? points,
    String? explanation,
    Grade? grade,
    String? chapter,
    Subject? subject,
    List<MultipleChoiceOptionData>? multipleChoiceOptions,
    bool? shuffleOptions,
    List<MatchingPairData>? matchingPairs,
    bool? shufflePairs,
    String? expectedAnswer,
    int? maxLength,
    List<SegmentData>? segments,
    bool? caseSensitive,
    bool? hasUnsavedChanges,
    bool? isLoading,
  }) {
    return QuestionFormState(
      questionId: questionId ?? this.questionId,
      title: title ?? this.title,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      titleImageUrl: titleImageUrl ?? this.titleImageUrl,
      points: points ?? this.points,
      explanation: explanation ?? this.explanation,
      grade: grade ?? this.grade,
      chapter: chapter ?? this.chapter,
      subject: subject ?? this.subject,
      multipleChoiceOptions:
          multipleChoiceOptions ?? this.multipleChoiceOptions,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
      matchingPairs: matchingPairs ?? this.matchingPairs,
      shufflePairs: shufflePairs ?? this.shufflePairs,
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      maxLength: maxLength ?? this.maxLength,
      segments: segments ?? this.segments,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Get the data payload for API submission based on question type
  Map<String, dynamic> getDataPayload() {
    switch (type) {
      case QuestionType.multipleChoice:
        return {
          'options': multipleChoiceOptions
              .map(
                (opt) => {
                  'text': opt.text,
                  'imageUrl': opt.imageUrl,
                  'isCorrect': opt.isCorrect,
                },
              )
              .toList(),
          'shuffleOptions': shuffleOptions,
        };

      case QuestionType.matching:
        return {
          'pairs': matchingPairs
              .map(
                (pair) => {
                  'leftText': pair.leftText,
                  'leftImageUrl': pair.leftImageUrl,
                  'rightText': pair.rightText,
                  'rightImageUrl': pair.rightImageUrl,
                },
              )
              .toList(),
          'shufflePairs': shufflePairs,
        };

      case QuestionType.openEnded:
        return {'expectedAnswer': expectedAnswer, 'maxLength': maxLength};

      case QuestionType.fillInBlank:
        return {
          'segments': segments.map((seg) => seg.toJson()).toList(),
          'caseSensitive': caseSensitive,
        };
    }
  }

  /// Validate the form based on question type
  String? validate() {
    // Basic validation
    if (title.trim().isEmpty) {
      return 'Title is required';
    }

    // Type-specific validation
    switch (type) {
      case QuestionType.multipleChoice:
        if (multipleChoiceOptions.isEmpty) {
          return 'Please add at least one option';
        }
        if (!multipleChoiceOptions.any((opt) => opt.isCorrect)) {
          return 'Please mark at least one option as correct';
        }
        if (multipleChoiceOptions.any((opt) => opt.text.trim().isEmpty)) {
          return 'All options must have text';
        }
        break;

      case QuestionType.matching:
        if (matchingPairs.isEmpty) {
          return 'Please add at least one matching pair';
        }
        if (matchingPairs.any(
          (pair) =>
              pair.leftText.trim().isEmpty || pair.rightText.trim().isEmpty,
        )) {
          return 'All matching pairs must have both left and right text';
        }
        break;

      case QuestionType.fillInBlank:
        if (segments.isEmpty) {
          return 'Please add at least one segment';
        }
        if (!segments.any((seg) => seg.type == SegmentType.blank)) {
          return 'Please add at least one blank segment';
        }
        if (segments.any((seg) => seg.content.trim().isEmpty)) {
          return 'All segments must have content';
        }
        break;

      case QuestionType.openEnded:
        // Open-ended has no specific validation requirements
        break;
    }

    return null; // Valid
  }
}
