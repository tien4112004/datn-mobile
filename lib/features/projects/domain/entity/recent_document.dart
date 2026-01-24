class RecentDocument {
  final String id;
  final String documentId;
  final String documentType;
  final String title;
  final String? thumbnail;
  final DateTime lastVisited;

  const RecentDocument({
    required this.id,
    required this.documentId,
    required this.documentType,
    required this.title,
    this.thumbnail,
    required this.lastVisited,
  });

  RecentDocument copyWith({
    String? id,
    String? documentId,
    String? documentType,
    String? title,
    String? thumbnail,
    DateTime? lastVisited,
  }) {
    return RecentDocument(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      lastVisited: lastVisited ?? this.lastVisited,
    );
  }
}
