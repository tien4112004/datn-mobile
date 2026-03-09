class PresentationMinimal {
  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? thumbnail;
  final String? grade;
  final String? subject;
  final String? chapter;

  const PresentationMinimal({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.grade,
    this.subject,
    this.chapter,
  });

  PresentationMinimal copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnail,
    String? grade,
    String? subject,
    String? chapter,
  }) {
    return PresentationMinimal(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      grade: grade ?? this.grade,
      subject: subject ?? this.subject,
      chapter: chapter ?? this.chapter,
    );
  }
}
