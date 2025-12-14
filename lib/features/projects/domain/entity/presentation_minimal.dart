class PresentationMinimal {
  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? thumbnail;

  const PresentationMinimal({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
  });

  PresentationMinimal copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnail,
  }) {
    return PresentationMinimal(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
