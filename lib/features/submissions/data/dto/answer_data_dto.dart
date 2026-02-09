import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/submissions/domain/entity/answer_entity.dart';
import 'package:AIPrimary/features/submissions/domain/entity/grade_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

part 'answer_data_dto.g.dart';

/// Abstract base class for answer data
/// Flattens the Dart structure but serializes to nested JSON for backend
abstract class AnswerDataDto {
  @JsonKey(name: 'id')
  final String questionId;

  final String type;

  const AnswerDataDto({required this.questionId, required this.type});

  factory AnswerDataDto.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    final answerData = json['answer'] as Map<String, dynamic>? ?? {};

    switch (type) {
      case 'MULTIPLE_CHOICE':
        return MultipleChoiceAnswerDataDto(
          questionId: json['id'] as String,
          selectedOptionId: answerData['id'] as String? ?? '',
        );
      case 'FILL_IN_BLANK':
        return FillInBlankAnswerDataDto(
          questionId: json['id'] as String,
          blankAnswers: Map<String, String>.from(
            answerData['blankAnswers'] as Map? ?? {},
          ),
        );
      case 'MATCHING':
        return MatchingAnswerDataDto(
          questionId: json['id'] as String,
          matchedPairs: Map<String, String>.from(
            answerData['matchedPairs'] as Map? ?? {},
          ),
        );
      case 'OPEN_ENDED':
        return OpenEndedAnswerDataDto(
          questionId: json['id'] as String,
          response: answerData['response'] as String? ?? '',
          responseUrl: answerData['responseUrl'] as String?,
        );
      default:
        throw Exception('Unknown answer type: $type');
    }
  }

  Map<String, dynamic> toJson();
}

/// Multiple Choice DTO
class MultipleChoiceAnswerDataDto extends AnswerDataDto {
  final String selectedOptionId;

  const MultipleChoiceAnswerDataDto({
    required super.questionId,
    required this.selectedOptionId,
  }) : super(type: 'MULTIPLE_CHOICE');

  @override
  Map<String, dynamic> toJson() => {
    'id': questionId,
    'type': type,
    'answer': {
      'type':
          type, // Including type in nested object as per some conventions, optional if backend doesn't need it
      'id': selectedOptionId,
    },
  };
}

/// Fill In Blank DTO
class FillInBlankAnswerDataDto extends AnswerDataDto {
  final Map<String, String> blankAnswers;

  const FillInBlankAnswerDataDto({
    required super.questionId,
    required this.blankAnswers,
  }) : super(type: 'FILL_IN_BLANK');

  @override
  Map<String, dynamic> toJson() => {
    'id': questionId,
    'type': type,
    'answer': {'type': type, 'blankAnswers': blankAnswers},
  };
}

/// Matching DTO
class MatchingAnswerDataDto extends AnswerDataDto {
  final Map<String, String> matchedPairs;

  const MatchingAnswerDataDto({
    required super.questionId,
    required this.matchedPairs,
  }) : super(type: 'MATCHING');

  @override
  Map<String, dynamic> toJson() => {
    'id': questionId,
    'type': type,
    'answer': {'type': type, 'matchedPairs': matchedPairs},
  };
}

/// Open Ended DTO
class OpenEndedAnswerDataDto extends AnswerDataDto {
  final String response;
  final String? responseUrl;

  const OpenEndedAnswerDataDto({
    required super.questionId,
    required this.response,
    this.responseUrl,
  }) : super(type: 'OPEN_ENDED');

  @override
  Map<String, dynamic> toJson() => {
    'id': questionId,
    'type': type,
    'answer': {'type': type, 'response': response, 'responseUrl': responseUrl},
  };
}

/// Extension to convert AnswerEntity to DTO for submission
extension AnswerEntityToDto on AnswerEntity {
  AnswerDataDto toDto() {
    switch (type) {
      case QuestionType.multipleChoice:
        final mcAnswer = this as MultipleChoiceAnswerEntity;
        return MultipleChoiceAnswerDataDto(
          questionId: questionId,
          selectedOptionId: mcAnswer.selectedOptionId ?? '',
        );

      case QuestionType.fillInBlank:
        final fibAnswer = this as FillInBlankAnswerEntity;
        return FillInBlankAnswerDataDto(
          questionId: questionId,
          blankAnswers: fibAnswer.blankAnswers,
        );

      case QuestionType.matching:
        final matchingAnswer = this as MatchingAnswerEntity;
        return MatchingAnswerDataDto(
          questionId: questionId,
          matchedPairs: matchingAnswer.matchedPairs,
        );

      case QuestionType.openEnded:
        final oeAnswer = this as OpenEndedAnswerEntity;
        // Assuming responseUrl is not in Entity yet or null, keeping it simple
        return OpenEndedAnswerDataDto(
          questionId: questionId,
          response: oeAnswer.response ?? '',
        );
    }
  }
}

/// Response DTO for answers returned from backend (includes grades)
/// Keeping this as is for now as it handles dynamic 'answer' parsing from backend
@JsonSerializable(explicitToJson: true)
class AnswerResponseDto {
  @JsonKey(name: 'id')
  final String questionId;

  final Map<String, dynamic>
  answer; // Backend returns dynamic answer structure with type inside

  final double? point;

  final String? feedback;

  @JsonKey(name: 'autoGraded')
  final bool autoGraded;

  const AnswerResponseDto({
    required this.questionId,
    required this.answer,
    this.point,
    this.feedback,
    required this.autoGraded,
  });

  factory AnswerResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AnswerResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerResponseDtoToJson(this);

  // Helper to extract type from answer object
  String get type => answer['type'] as String? ?? '';
}

/// Extension to convert response DTO to entity
extension AnswerResponseDtoToEntity on AnswerResponseDto {
  AnswerEntity toEntity() {
    final questionType = QuestionType.fromApiValue(type);

    // Build grade entity from flat fields if point is not null
    final gradeEntity = point != null
        ? GradeEntity(
            score: point!,
            maxScore:
                point!, // Backend doesn't provide maxScore separately, using point value
            feedback: feedback,
            isAutoGraded: autoGraded,
          )
        : null;

    switch (questionType) {
      case QuestionType.multipleChoice:
        return MultipleChoiceAnswerEntity(
          questionId: questionId,
          selectedOptionId: answer['id'] as String?,
          grade: gradeEntity,
        );

      case QuestionType.fillInBlank:
        return FillInBlankAnswerEntity(
          questionId: questionId,
          blankAnswers: Map<String, String>.from(
            answer['blankAnswers'] as Map? ?? {},
          ),
          grade: gradeEntity,
        );

      case QuestionType.matching:
        return MatchingAnswerEntity(
          questionId: questionId,
          matchedPairs: Map<String, String>.from(
            answer['matchedPairs'] as Map? ?? {},
          ),
          grade: gradeEntity,
        );

      case QuestionType.openEnded:
        return OpenEndedAnswerEntity(
          questionId: questionId,
          response: answer['response'] as String?,
          grade: gradeEntity,
        );
    }
  }
}
