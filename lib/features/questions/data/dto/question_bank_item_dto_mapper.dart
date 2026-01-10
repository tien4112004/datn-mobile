import 'package:datn_mobile/features/questions/data/dto/question_bank_item_dto.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';

/// Extension for mapping QuestionBankItemDto to domain entity.
extension QuestionBankItemDtoMapper on QuestionBankItemDto {
  QuestionBankItemEntity toEntity() {
    final questionType = _parseQuestionType(type);
    final difficulty = Difficulty.fromApiValue(this.difficulty);

    final BaseQuestion question;

    switch (questionType) {
      case QuestionType.multipleChoice:
        question = MultipleChoiceQuestion(
          id: id,
          difficulty: difficulty,
          title: title,
          titleImageUrl: titleImageUrl,
          explanation: explanation,
          points: points,
          data: _parseMultipleChoiceData(data),
        );
        break;
      case QuestionType.matching:
        question = MatchingQuestion(
          id: id,
          difficulty: difficulty,
          title: title,
          titleImageUrl: titleImageUrl,
          explanation: explanation,
          points: points,
          data: _parseMatchingData(data),
        );
        break;
      case QuestionType.openEnded:
        question = OpenEndedQuestion(
          id: id,
          difficulty: difficulty,
          title: title,
          titleImageUrl: titleImageUrl,
          explanation: explanation,
          points: points,
          data: _parseOpenEndedData(data),
        );
        break;
      case QuestionType.fillInBlank:
        question = FillInBlankQuestion(
          id: id,
          difficulty: difficulty,
          title: title,
          titleImageUrl: titleImageUrl,
          explanation: explanation,
          points: points,
          data: _parseFillInBlankData(data),
        );
        break;
    }

    return QuestionBankItemEntity(
      id: id,
      question: question,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  QuestionType _parseQuestionType(String type) {
    switch (type.toUpperCase()) {
      case 'MULTIPLE_CHOICE':
        return QuestionType.multipleChoice;
      case 'MATCHING':
        return QuestionType.matching;
      case 'OPEN_ENDED':
        return QuestionType.openEnded;
      case 'FILL_IN_THE_BLANK':
        return QuestionType.fillInBlank;
      default:
        return QuestionType.multipleChoice;
    }
  }

  MultipleChoiceData _parseMultipleChoiceData(Map<String, dynamic> data) {
    final options =
        (data['options'] as List<dynamic>?)
            ?.map(
              (o) => MultipleChoiceOption(
                id: o['id'] as String,
                text: o['text'] as String,
                imageUrl: o['imageUrl'] as String?,
                isCorrect: o['isCorrect'] as bool,
              ),
            )
            .toList() ??
        [];

    return MultipleChoiceData(
      options: options,
      shuffleOptions: data['shuffleOptions'] as bool? ?? false,
    );
  }

  MatchingData _parseMatchingData(Map<String, dynamic> data) {
    final pairs =
        (data['pairs'] as List<dynamic>?)
            ?.map(
              (p) => MatchingPair(
                id: p['id'] as String,
                left: p['left'] as String,
                leftImageUrl: p['leftImageUrl'] as String?,
                right: p['right'] as String,
                rightImageUrl: p['rightImageUrl'] as String?,
              ),
            )
            .toList() ??
        [];

    return MatchingData(
      pairs: pairs,
      shufflePairs: data['shufflePairs'] as bool? ?? false,
    );
  }

  OpenEndedData _parseOpenEndedData(Map<String, dynamic> data) {
    return OpenEndedData(
      expectedAnswer: data['expectedAnswer'] as String?,
      maxLength: data['maxLength'] as int?,
    );
  }

  FillInBlankData _parseFillInBlankData(Map<String, dynamic> data) {
    final segments =
        (data['segments'] as List<dynamic>?)
            ?.map(
              (s) => BlankSegment(
                id: s['id'] as String,
                type: s['type'] == 'blank'
                    ? SegmentType.blank
                    : SegmentType.text,
                content: s['content'] as String,
                acceptableAnswers: s['type'] == 'blank'
                    ? (s['acceptableAnswers'] as List<dynamic>?)
                          ?.map((a) => a as String)
                          .toList()
                    : null,
              ),
            )
            .toList() ??
        [];

    return FillInBlankData(
      segments: segments,
      caseSensitive: data['caseSensitive'] as bool? ?? false,
    );
  }
}
