import 'package:AIPrimary/features/classes/domain/entity/permission_level.dart';

class LinkedResourceEntity {
  final String id;
  final String type;
  final PermissionLevel permissionLevel;
  final String?
  title; // Enriched by backend (optional for backward compatibility)
  final String?
  thumbnail; // Enriched by backend (optional, null for assignments)

  const LinkedResourceEntity({
    required this.id,
    required this.type,
    required this.permissionLevel,
    this.title,
    this.thumbnail,
  });

  LinkedResourceEntity copyWith({
    String? id,
    String? type,
    PermissionLevel? permissionLevel,
    String? title,
    String? thumbnail,
  }) => LinkedResourceEntity(
    id: id ?? this.id,
    type: type ?? this.type,
    permissionLevel: permissionLevel ?? this.permissionLevel,
    title: title ?? this.title,
    thumbnail: thumbnail ?? this.thumbnail,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedResourceEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
