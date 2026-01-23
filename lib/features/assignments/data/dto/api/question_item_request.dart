import 'package:json_annotation/json_annotation.dart';

part 'question_item_request.g.dart';

/// API-compliant DTO for question item in request.
/// Matches QuestionItemRequest from ASSIGNMENT_API_DOCS.md
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class QuestionItemRequest {
  final String? id; // Optional in create request
  final String type; // MULTIPLE_CHOICE, MATCHING, OPEN_ENDED, FILL_IN_BLANK
  final String?
  difficulty; // KNOWLEDGE, COMPREHENSION, APPLICATION, ADVANCED_APPLICATION
  final String? title;
  final String? titleImageUrl;
  final String? explanation;
  final String? grade;
  final String? chapter;
  final String? subject;
  final double? point;
  final Map<String, dynamic>? data; // Polymorphic data based on type

  const QuestionItemRequest({
    this.id,
    required this.type,
    this.difficulty,
    this.title,
    this.titleImageUrl,
    this.explanation,
    this.grade,
    this.chapter,
    this.subject,
    this.point,
    this.data,
  });

  factory QuestionItemRequest.fromJson(Map<String, dynamic> json) =>
      _$QuestionItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionItemRequestToJson(this);
}
