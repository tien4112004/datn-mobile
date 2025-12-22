class ImageProject {
  String id;
  String title;
  String imageUrl;
  DateTime createdAt;
  DateTime updatedAt;
  String? description;

  ImageProject({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
    };
  }
}
