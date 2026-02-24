import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

part 'question_response.g.dart';

/// API-compliant DTO for question in response.
/// Matches Question structure from ASSIGNMENT_API_DOCS.md
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class QuestionResponse {
  final String? id;
  final String type; // MULTIPLE_CHOICE, MATCHING, OPEN_ENDED, FILL_IN_BLANK
  final String? difficulty; // KNOWLEDGE, COMPREHENSION, APPLICATION
  final String? title;
  final String? titleImageUrl;
  final String? explanation;
  final String? grade;
  final String? chapter;
  final String? subject;
  final String? contextId; // Context ID for questions with reading passage
  final String? topicId; // Subtopic ID for matrix mapping
  final double? point;
  final Map<String, dynamic>? data; // Polymorphic data based on type

  const QuestionResponse({
    this.id,
    required this.type,
    this.difficulty,
    this.title,
    this.titleImageUrl,
    this.explanation,
    this.grade,
    this.chapter,
    this.subject,
    this.contextId,
    this.topicId,
    this.point,
    this.data,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$QuestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionResponseToJson(this);
}

/// Extension to map QuestionResponse to AssignmentQuestionEntity
extension QuestionResponseMapper on QuestionResponse {
  /// Convert QuestionResponse to AssignmentQuestionEntity
  AssignmentQuestionEntity toEntity() {
    // Parse polymorphic data Map based on type
    final BaseQuestion question = _parseQuestionData();
    final isNew = id == null || id!.startsWith('new_');

    return AssignmentQuestionEntity(
      questionBankId: isNew ? null : id,
      question: question,
      points: point ?? 0.0,
      isNewQuestion: isNew,
      contextId: contextId,
      topicId: topicId ?? chapter,
    );
  }

  /// Parse the polymorphic data field into a BaseQuestion
  BaseQuestion _parseQuestionData() {
    final questionType = QuestionType.fromApiValue(type);
    final questionDifficulty = difficulty != null
        ? Difficulty.fromApiValue(difficulty!)
        : Difficulty.knowledge;
    final questionTitle = title ?? '';
    final questionId = id ?? '';

    if (data == null) {
      throw Exception('Question data is null for question $id');
    }

    switch (questionType) {
      case QuestionType.multipleChoice:
        return _parseMultipleChoice(
          questionId,
          questionTitle,
          questionDifficulty,
          data!,
        );

      case QuestionType.matching:
        return _parseMatching(
          questionId,
          questionTitle,
          questionDifficulty,
          data!,
        );

      case QuestionType.fillInBlank:
        return _parseFillInBlank(
          questionId,
          questionTitle,
          questionDifficulty,
          data!,
        );

      case QuestionType.openEnded:
        return _parseOpenEnded(
          questionId,
          questionTitle,
          questionDifficulty,
          data!,
        );
    }
  }

  /// Parse Multiple Choice question data
  MultipleChoiceQuestion _parseMultipleChoice(
    String id,
    String title,
    Difficulty difficulty,
    Map<String, dynamic> data,
  ) {
    final optionsList = (data['options'] as List<dynamic>?) ?? [];
    final options = optionsList.asMap().entries.map((entry) {
      final index = entry.key;
      final optMap = entry.value as Map<String, dynamic>;
      final rawId = optMap['id']?.toString() ?? '';
      return MultipleChoiceOption(
        // Fall back to index-based id if the API returns null/empty,
        // so each option always has a unique identifier.
        id: rawId.isNotEmpty ? rawId : 'option_$index',
        text: optMap['text']?.toString() ?? '',
        imageUrl: optMap['imageUrl']?.toString(),
        isCorrect: optMap['isCorrect'] as bool? ?? false,
      );
    }).toList();

    return MultipleChoiceQuestion(
      id: id,
      difficulty: difficulty,
      title: title,
      titleImageUrl: titleImageUrl,
      explanation: explanation,
      data: MultipleChoiceData(
        options: options,
        shuffleOptions: data['shuffleOptions'] as bool? ?? false,
      ),
    );
  }

  /// Parse Matching question data
  MatchingQuestion _parseMatching(
    String id,
    String title,
    Difficulty difficulty,
    Map<String, dynamic> data,
  ) {
    final pairsList = (data['pairs'] as List<dynamic>?) ?? [];
    final pairs = pairsList.map((pair) {
      final pairMap = pair as Map<String, dynamic>;
      return MatchingPair(
        id: pairMap['id']?.toString() ?? '',
        left: (pairMap['leftText'] ?? pairMap['left'])?.toString() ?? '',
        leftImageUrl: pairMap['leftImageUrl']?.toString(),
        right: (pairMap['rightText'] ?? pairMap['right'])?.toString() ?? '',
        rightImageUrl: pairMap['rightImageUrl']?.toString(),
      );
    }).toList();

    return MatchingQuestion(
      id: id,
      difficulty: difficulty,
      title: title,
      titleImageUrl: titleImageUrl,
      explanation: explanation,
      data: MatchingData(
        pairs: pairs,
        shufflePairs: data['shufflePairs'] as bool? ?? false,
      ),
    );
  }

  /// Parse Fill in Blank question data
  FillInBlankQuestion _parseFillInBlank(
    String id,
    String title,
    Difficulty difficulty,
    Map<String, dynamic> data,
  ) {
    final segmentsList = (data['segments'] as List<dynamic>?) ?? [];
    final segments = segmentsList.map((seg) {
      final segMap = seg as Map<String, dynamic>;
      final segType = segMap['type']?.toString().toUpperCase() == 'BLANK'
          ? SegmentType.blank
          : SegmentType.text;

      return BlankSegment(
        id: segMap['id']?.toString() ?? '',
        type: segType,
        content: segMap['content']?.toString() ?? '',
        acceptableAnswers: (segMap['acceptableAnswers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );
    }).toList();

    return FillInBlankQuestion(
      id: id,
      difficulty: difficulty,
      title: title,
      titleImageUrl: titleImageUrl,
      explanation: explanation,
      data: FillInBlankData(
        segments: segments,
        caseSensitive: data['caseSensitive'] as bool? ?? false,
      ),
    );
  }

  /// Parse Open Ended question data
  OpenEndedQuestion _parseOpenEnded(
    String id,
    String title,
    Difficulty difficulty,
    Map<String, dynamic> data,
  ) {
    return OpenEndedQuestion(
      id: id,
      difficulty: difficulty,
      title: title,
      titleImageUrl: titleImageUrl,
      explanation: explanation,
      data: OpenEndedData(
        expectedAnswer: data['expectedAnswer']?.toString(),
        maxLength: data['maxLength'] as int?,
      ),
    );
  }
}
