import 'package:datn_mobile/features/classes/domain/entity/permission_level.dart';

class LinkedResourceEntity {
  final String id;
  final String type;
  final PermissionLevel permissionLevel;

  const LinkedResourceEntity({
    required this.id,
    required this.type,
    required this.permissionLevel,
  });

  LinkedResourceEntity copyWith({
    String? id,
    String? type,
    PermissionLevel? permissionLevel,
  }) => LinkedResourceEntity(
    id: id ?? this.id,
    type: type ?? this.type,
    permissionLevel: permissionLevel ?? this.permissionLevel,
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
