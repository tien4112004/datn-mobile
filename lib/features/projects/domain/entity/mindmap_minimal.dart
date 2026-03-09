class MindmapMinimal {
  final String id;
  final String title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? thumbnail;
  final String? grade;
  final String? subject;
  final String? chapter;

  const MindmapMinimal({
    required this.id,
    required this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.grade,
    this.subject,
    this.chapter,
  });

  MindmapMinimal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnail,
    String? grade,
    String? subject,
    String? chapter,
  }) {
    return MindmapMinimal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      grade: grade ?? this.grade,
      subject: subject ?? this.subject,
      chapter: chapter ?? this.chapter,
    );
  }
}
