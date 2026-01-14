class ImageProjectMinimal {
  final String id;
  final String title;
  final String url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ImageProjectMinimal({
    required this.id,
    required this.title,
    required this.url,
    this.createdAt,
    this.updatedAt,
  });

  ImageProjectMinimal copyWith({
    String? id,
    String? title,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ImageProjectMinimal(
      id: id ?? this.id,
      title: title ?? this.title,
      url: imageUrl ?? url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
