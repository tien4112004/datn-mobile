/// Domain entity for a reading passage context.
/// Pure business object without JSON annotations.
class ContextEntity {
  final String id;
  final String title;
  final String content;
  final String? subject;
  final int? grade;
  final String? author;
  final bool? fromBook;
  final String? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// For cloned contexts, tracks the original source context ID
  final String? sourceContextId;

  const ContextEntity({
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
    this.sourceContextId,
  });

  /// Check if this is a cloned context (has source reference)
  bool get isCloned => sourceContextId != null;

  /// Check if this is a public context (no owner)
  bool get isPublic => ownerId == null;

  ContextEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? subject,
    int? grade,
    String? author,
    bool? fromBook,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceContextId,
  }) {
    return ContextEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      author: author ?? this.author,
      fromBook: fromBook ?? this.fromBook,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceContextId: sourceContextId ?? this.sourceContextId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ContextEntity &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.subject == subject &&
        other.grade == grade &&
        other.author == author &&
        other.fromBook == fromBook &&
        other.ownerId == ownerId &&
        other.sourceContextId == sourceContextId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      subject,
      grade,
      author,
      fromBook,
      ownerId,
      sourceContextId,
    );
  }

  @override
  String toString() {
    return 'ContextEntity(id: $id, title: $title, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}
