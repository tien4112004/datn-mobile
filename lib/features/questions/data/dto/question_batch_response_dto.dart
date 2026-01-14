import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/questions/data/dto/question_bank_item_dto.dart';

part 'question_batch_response_dto.g.dart';

/// Failed question creation info.
@JsonSerializable()
class FailedQuestionDto {
  final int index;
  final String title;
  final String errorMessage;
  final Map<String, dynamic>? fieldErrors;

  FailedQuestionDto({
    required this.index,
    required this.title,
    required this.errorMessage,
    this.fieldErrors,
  });

  factory FailedQuestionDto.fromJson(Map<String, dynamic> json) =>
      _$FailedQuestionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FailedQuestionDtoToJson(this);
}

/// Batch creation result data.
@JsonSerializable()
class BatchResultDto {
  final List<QuestionBankItemDto> successful;
  final List<FailedQuestionDto> failed;
  final int totalProcessed;
  final int totalSuccessful;
  final int totalFailed;

  BatchResultDto({
    required this.successful,
    required this.failed,
    required this.totalProcessed,
    required this.totalSuccessful,
    required this.totalFailed,
  });

  factory BatchResultDto.fromJson(Map<String, dynamic> json) =>
      _$BatchResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BatchResultDtoToJson(this);
}

/// Response DTO for batch question creation.
@JsonSerializable()
class QuestionBatchResponseDto {
  final bool success;
  final int code;
  final BatchResultDto data;

  QuestionBatchResponseDto({
    required this.success,
    required this.code,
    required this.data,
  });

  factory QuestionBatchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionBatchResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionBatchResponseDtoToJson(this);
}
