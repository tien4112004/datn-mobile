import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'question_bank_item_dto.g.dart';

/// Converter to handle `data` field that may come as a JSON string or a Map.
class DataJsonConverter implements JsonConverter<Map<String, dynamic>, Object> {
  const DataJsonConverter();

  @override
  Map<String, dynamic> fromJson(Object json) {
    if (json is String) {
      return jsonDecode(json) as Map<String, dynamic>;
    }
    return json as Map<String, dynamic>;
  }

  @override
  Object toJson(Map<String, dynamic> object) => object;
}

/// DTO for individual question item in question bank list.
@JsonSerializable()
class QuestionBankItemDto {
  final String id;
  final String title;
  final String type; // MULTIPLE_CHOICE, MATCHING, FILL_IN_BLANK, OPEN_ENDED
  final String difficulty; // KNOWLEDGE, COMPREHENSION, APPLICATION
  final String? explanation;
  final String? titleImageUrl;
  @DataJsonConverter()
  final Map<String, dynamic> data;
  final String? ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String grade;
  final String? chapter;
  final String? subject;

  QuestionBankItemDto({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    this.explanation,
    this.titleImageUrl,
    required this.data,
    this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.grade,
    this.chapter,
    this.subject,
  });

  factory QuestionBankItemDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionBankItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionBankItemDtoToJson(this);
}
