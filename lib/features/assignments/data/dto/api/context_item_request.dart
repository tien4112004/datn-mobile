import 'package:json_annotation/json_annotation.dart';

part 'context_item_request.g.dart';

/// API-compliant DTO for context item in assignment create/update requests.
/// Matches the web frontend's AssignmentContext shape: { id, title, content, author? }
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class ContextItemRequest {
  final String? id;
  final String title;
  final String content;
  final String? author;

  const ContextItemRequest({
    this.id,
    required this.title,
    required this.content,
    this.author,
  });

  factory ContextItemRequest.fromJson(Map<String, dynamic> json) =>
      _$ContextItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ContextItemRequestToJson(this);
}
