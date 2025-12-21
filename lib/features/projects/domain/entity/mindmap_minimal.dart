class MindmapMinimal {
  final String id;
  final String title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MindmapMinimal({
    required this.id,
    required this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  MindmapMinimal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MindmapMinimal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
