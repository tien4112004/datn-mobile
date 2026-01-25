import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:datn_mobile/features/classes/domain/entity/linked_resource_entity.dart';

/// Domain entity representing a class post.
/// This is a pure domain model without any JSON serialization logic.
class PostEntity {
  final String id;
  final String classId;
  final String authorId;
  final String authorName;
  final String authorEmail;
  final String content;
  final PostType type;
  final List<String> attachments;
  final List<LinkedResourceEntity> linkedResources;
  final String? linkedLessonId;
  final DateTime? dueDate; // For exercise type posts
  final bool isPinned;
  final bool allowComments;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostEntity({
    required this.id,
    required this.classId,
    required this.authorId,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    required this.type,
    required this.attachments,
    required this.linkedResources,
    this.linkedLessonId,
    this.dueDate,
    required this.isPinned,
    required this.allowComments,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this entity with the specified fields replaced
  PostEntity copyWith({
    String? id,
    String? classId,
    String? authorId,
    String? authorName,
    String? authorEmail,
    String? content,
    PostType? type,
    List<String>? attachments,
    List<LinkedResourceEntity>? linkedResources,
    String? linkedLessonId,
    DateTime? dueDate,
    bool? isPinned,
    bool? allowComments,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      content: content ?? this.content,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      linkedResources: linkedResources ?? this.linkedResources,
      linkedLessonId: linkedLessonId ?? this.linkedLessonId,
      dueDate: dueDate ?? this.dueDate,
      isPinned: isPinned ?? this.isPinned,
      allowComments: allowComments ?? this.allowComments,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PostEntity(id: $id, type: $type, isPinned: $isPinned)';
}
