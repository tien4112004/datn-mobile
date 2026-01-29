class SharedResource {
  final String id;
  final String type;
  final String title;
  final String permission;
  final String? thumbnailUrl;
  final String ownerId;
  final String ownerName;

  const SharedResource({
    required this.id,
    required this.type,
    required this.title,
    required this.permission,
    this.thumbnailUrl,
    required this.ownerId,
    required this.ownerName,
  });

  SharedResource copyWith({
    String? id,
    String? type,
    String? title,
    String? permission,
    String? thumbnailUrl,
    String? ownerId,
    String? ownerName,
  }) {
    return SharedResource(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      permission: permission ?? this.permission,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
    );
  }
}
