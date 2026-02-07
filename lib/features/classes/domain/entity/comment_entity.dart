/// Domain entity representing a comment on a post.
/// This is a pure domain model without any JSON serialization logic.
class CommentEntity {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // User details from the comment response
  final String? authorName;
  final String? authorEmail;
  final String? authorAvatarUrl;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.createdAt,
    this.updatedAt,
    this.authorName,
    this.authorEmail,
    this.authorAvatarUrl,
  });

  /// Creates a copy of this entity with the specified fields replaced
  CommentEntity copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorEmail,
    String? authorAvatarUrl,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CommentEntity(id: $id, postId: $postId)';
}
