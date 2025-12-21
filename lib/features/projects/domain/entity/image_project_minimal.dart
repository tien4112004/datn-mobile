class ImageProjectMinimal {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ImageProjectMinimal({
    required this.id,
    required this.title,
    required this.imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
