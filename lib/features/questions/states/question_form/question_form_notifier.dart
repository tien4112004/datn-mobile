import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/features/questions/states/question_form/question_form_state.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/fill_in_blank_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/matching_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/multiple_choice_section.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Notifier for managing question form state
class QuestionFormNotifier extends StateNotifier<QuestionFormState> {
  QuestionFormNotifier() : super(const QuestionFormState());

  /// Initialize form for creating a new question
  void initializeForCreate() {
    state = const QuestionFormState();
  }

  /// Initialize form for editing an existing question
  void initializeForEdit(
    String questionId, {
    required String title,
    required QuestionType type,
    required Difficulty difficulty,
    String? titleImageUrl,
    String? explanation,
    String? grade,
    String? chapter,
    String? subject,
    required Map<String, dynamic> data,
  }) {
    state = QuestionFormState(
      questionId: questionId,
      title: title,
      type: type,
      difficulty: difficulty,
      titleImageUrl: titleImageUrl,
      explanation: explanation ?? '',
      grade:
          (grade != null ? GradeLevel.fromApiValue(grade) : null) ??
          GradeLevel.grade1,
      chapter: chapter,
      subject:
          (subject != null ? Subject.fromApiValue(subject) : null) ??
          Subject.english,
      hasUnsavedChanges: false,
    );

    // Load type-specific data
    _loadTypeSpecificData(data);
  }

  void _loadTypeSpecificData(Map<String, dynamic> data) {
    switch (state.type) {
      case QuestionType.multipleChoice:
        final options =
            (data['options'] as List?)
                ?.map(
                  (opt) => MultipleChoiceOptionData(
                    text: opt['text'] as String,
                    imageUrl: opt['imageUrl'] as String?,
                    isCorrect: opt['isCorrect'] as bool,
                  ),
                )
                .toList() ??
            [];
        state = state.copyWith(
          multipleChoiceOptions: options,
          shuffleOptions: data['shuffleOptions'] as bool? ?? false,
        );
        break;

      case QuestionType.matching:
        final pairs =
            (data['pairs'] as List?)
                ?.map(
                  (pair) => MatchingPairData(
                    leftText: pair['leftText'] as String,
                    leftImageUrl: pair['leftImageUrl'] as String?,
                    rightText: pair['rightText'] as String,
                    rightImageUrl: pair['rightImageUrl'] as String?,
                  ),
                )
                .toList() ??
            [];
        state = state.copyWith(
          matchingPairs: pairs,
          shufflePairs: data['shufflePairs'] as bool? ?? false,
        );
        break;

      case QuestionType.openEnded:
        state = state.copyWith(
          expectedAnswer: data['expectedAnswer'] as String?,
          maxLength: data['maxLength'] as int?,
        );
        break;

      case QuestionType.fillInBlank:
        final segments =
            (data['segments'] as List?)
                ?.map(
                  (seg) => SegmentData.fromJson(seg as Map<String, dynamic>),
                )
                .toList() ??
            [];
        state = state.copyWith(
          segments: segments,
          caseSensitive: data['caseSensitive'] as bool? ?? false,
        );
        break;
    }
  }

  // === Basic Information Updates ===

  void updateTitle(String title) {
    state = state.copyWith(title: title, hasUnsavedChanges: true);
  }

  void updateType(QuestionType type) {
    state = state.copyWith(type: type, hasUnsavedChanges: true);
  }

  void updateDifficulty(Difficulty difficulty) {
    state = state.copyWith(difficulty: difficulty, hasUnsavedChanges: true);
  }

  void updateTitleImageUrl(String? url) {
    state = state.copyWith(titleImageUrl: url, hasUnsavedChanges: true);
  }

  void updatePoints(int points) {
    state = state.copyWith(points: points, hasUnsavedChanges: true);
  }

  void updateExplanation(String explanation) {
    state = state.copyWith(explanation: explanation, hasUnsavedChanges: true);
  }

  void updateGrade(GradeLevel grade) {
    state = state.copyWith(grade: grade, hasUnsavedChanges: true);
  }

  void updateChapter(String chapter) {
    state = state.copyWith(chapter: chapter, hasUnsavedChanges: true);
  }

  void updateSubject(Subject subject) {
    state = state.copyWith(subject: subject, hasUnsavedChanges: true);
  }

  // === Multiple Choice Updates ===

  void updateMultipleChoiceOptions(List<MultipleChoiceOptionData> options) {
    state = state.copyWith(
      multipleChoiceOptions: options,
      hasUnsavedChanges: true,
    );
  }

  void updateShuffleOptions(bool shuffle) {
    state = state.copyWith(shuffleOptions: shuffle, hasUnsavedChanges: true);
  }

  // === Matching Updates ===

  void updateMatchingPairs(List<MatchingPairData> pairs) {
    state = state.copyWith(matchingPairs: pairs, hasUnsavedChanges: true);
  }

  void updateShufflePairs(bool shuffle) {
    state = state.copyWith(shufflePairs: shuffle, hasUnsavedChanges: true);
  }

  // === Open Ended Updates ===

  void updateExpectedAnswer(String? answer) {
    state = state.copyWith(expectedAnswer: answer, hasUnsavedChanges: true);
  }

  void updateMaxLength(int? length) {
    state = state.copyWith(maxLength: length, hasUnsavedChanges: true);
  }

  // === Fill in Blank Updates ===

  void updateSegments(List<SegmentData> segments) {
    state = state.copyWith(segments: segments, hasUnsavedChanges: true);
  }

  void updateCaseSensitive(bool caseSensitive) {
    state = state.copyWith(
      caseSensitive: caseSensitive,
      hasUnsavedChanges: true,
    );
  }

  // === Form State Management ===

  void markSaved() {
    state = state.copyWith(hasUnsavedChanges: false);
  }

  /// Reset form to initial state
  void reset() {
    state = const QuestionFormState();
  }
}
