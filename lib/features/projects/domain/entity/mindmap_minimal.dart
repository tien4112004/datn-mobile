class MindmapMinimal {
  final String id;
  final String title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? thumbnail;

  const MindmapMinimal({
    required this.id,
    required this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
  });

  MindmapMinimal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnail,
  }) {
    return MindmapMinimal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
