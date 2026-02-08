import 'package:AIPrimary/features/assignments/data/dto/api/context_item_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/question_item_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_update_request.g.dart';

/// API-compliant DTO for updating an existing assignment.
/// Matches AssignmentUpdateRequest from ASSIGNMENT_API_DOCS.md
@JsonSerializable(includeIfNull: false)
class AssignmentUpdateRequest {
  final String? title;
  final String? description;
  final int? duration; // Duration in minutes (null for no limit)
  final String? subject;
  final String? grade;
  final List<QuestionItemRequest>?
  questions; // Replaces existing questions list
  final List<ContextItemRequest>? contexts;

  const AssignmentUpdateRequest({
    this.title,
    this.description,
    this.duration,
    this.subject,
    this.grade,
    this.questions,
    this.contexts,
  });

  factory AssignmentUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignmentUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentUpdateRequestToJson(this);
}
