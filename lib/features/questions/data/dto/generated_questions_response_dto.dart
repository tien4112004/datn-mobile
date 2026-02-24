import 'package:AIPrimary/features/questions/data/dto/question_bank_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated_questions_response_dto.g.dart';

@JsonSerializable()
class GeneratedQuestionsResponseDto {
  final int totalGenerated;
  final List<QuestionBankItemDto> questions;

  GeneratedQuestionsResponseDto({
    required this.totalGenerated,
    required this.questions,
  });

  factory GeneratedQuestionsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GeneratedQuestionsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedQuestionsResponseDtoToJson(this);
}
