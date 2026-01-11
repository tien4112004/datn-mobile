import 'package:datn_mobile/features/questions/data/dto/question_create_request_dto.dart';
import 'package:datn_mobile/features/questions/data/dto/question_update_request_dto.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_create_request_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_update_request_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';

/// Extensions to convert between domain entities and DTOs for question requests.

extension QuestionCreateRequestEntityMapper on QuestionCreateRequestEntity {
  /// Converts domain entity to DTO.
  QuestionCreateRequestDto toDto() {
    return QuestionCreateRequestDto(
      title: title,
      type: _questionTypeToApiValue(type),
      difficulty: difficulty.apiValue,
      explanation: explanation,
      titleImageUrl: titleImageUrl,
      points: points,
      data: data,
    );
  }
}

extension QuestionUpdateRequestEntityMapper on QuestionUpdateRequestEntity {
  /// Converts domain entity to DTO.
  QuestionUpdateRequestDto toDto() {
    return QuestionUpdateRequestDto(
      title: title,
      type: type != null ? _questionTypeToApiValue(type!) : null,
      difficulty: difficulty?.apiValue,
      explanation: explanation,
      titleImageUrl: titleImageUrl,
      points: points,
      data: data,
    );
  }
}

/// Helper to convert QuestionType enum to API string value.
String _questionTypeToApiValue(QuestionType type) {
  switch (type) {
    case QuestionType.multipleChoice:
      return 'MULTIPLE_CHOICE';
    case QuestionType.matching:
      return 'MATCHING';
    case QuestionType.fillInBlank:
      return 'FILL_IN_BLANK';
    case QuestionType.openEnded:
      return 'OPEN_ENDED';
  }
}
