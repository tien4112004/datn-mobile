import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';

part 'context_response.g.dart';

/// API-compliant DTO for context in response.
/// Matches Context structure from backend ContextResponse.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class ContextResponse {
  final String id;
  final String title;
  final String content;
  final String? subject;
  final int? grade;
  final String? author;
  final bool? fromBook;
  final String? ownerId;
  final String? createdAt;
  final String? updatedAt;

  const ContextResponse({
    required this.id,
    required this.title,
    required this.content,
    this.subject,
    this.grade,
    this.author,
    this.fromBook,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  factory ContextResponse.fromJson(Map<String, dynamic> json) =>
      _$ContextResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ContextResponseToJson(this);
}

/// Extension to map ContextResponse to ContextEntity
extension ContextResponseMapper on ContextResponse {
  /// Convert ContextResponse to ContextEntity
  ContextEntity toEntity({String? sourceContextId}) {
    return ContextEntity(
      id: id,
      title: title,
      content: content,
      subject: subject,
      grade: grade,
      author: author,
      fromBook: fromBook,
      ownerId: ownerId,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      sourceContextId: sourceContextId,
    );
  }
}
