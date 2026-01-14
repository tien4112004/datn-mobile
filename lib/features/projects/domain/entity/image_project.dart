class ImageProject {
  String id;
  String title; // Maps from API's originalFilename
  String imageUrl; // Maps from API's url
  DateTime createdAt;
  DateTime updatedAt;
  String? description;
  String? mediaType; // New field from IMAGE_API.md
  int? fileSize; // New field from IMAGE_API.md

  ImageProject({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.mediaType,
    this.fileSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'mediaType': mediaType,
      'fileSize': fileSize,
    };
  }
}
