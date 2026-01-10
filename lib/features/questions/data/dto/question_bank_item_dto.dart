import 'package:json_annotation/json_annotation.dart';

part 'question_bank_item_dto.g.dart';

/// DTO for individual question item in question bank list.
@JsonSerializable()
class QuestionBankItemDto {
  final String id;
  final String title;
  final String type; // MULTIPLE_CHOICE, MATCHING, FILL_IN_THE_BLANK, OPEN_ENDED
  final String
  difficulty; // KNOWLEDGE, COMPREHENSION, APPLICATION, ADVANCED_APPLICATION
  final String? explanation;
  final String? titleImageUrl;
  final int? points;
  final Map<String, dynamic> data;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestionBankItemDto({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    this.explanation,
    this.titleImageUrl,
    this.points,
    required this.data,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionBankItemDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionBankItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionBankItemDtoToJson(this);
}
