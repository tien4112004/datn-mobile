import 'package:AIPrimary/features/assignments/data/dto/api/context_item_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/question_item_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_create_request.g.dart';

/// API-compliant DTO for creating a new assignment.
/// Matches AssignmentCreateRequest from ASSIGNMENT_API_DOCS.md
@JsonSerializable(includeIfNull: false)
class AssignmentCreateRequest {
  final String title;
  final String? description;
  final String? subject;
  final String? grade;
  final List<QuestionItemRequest>? questions;
  final List<ContextItemRequest>? contexts;

  const AssignmentCreateRequest({
    required this.title,
    this.description,
    this.subject,
    this.grade,
    this.questions,
    this.contexts,
  });

  factory AssignmentCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignmentCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentCreateRequestToJson(this);
}
