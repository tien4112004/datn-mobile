import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:datn_mobile/features/classes/domain/entity/permission_level.dart';

part 'linked_resource_dto.g.dart';

@JsonSerializable()
class LinkedResourceDto {
  final String id;
  final String type;
  final String permissionLevel;

  const LinkedResourceDto({
    required this.id,
    required this.type,
    required this.permissionLevel,
  });

  factory LinkedResourceDto.fromJson(Map<String, dynamic> json) =>
      _$LinkedResourceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LinkedResourceDtoToJson(this);
}

extension LinkedResourceDtoMapper on LinkedResourceDto {
  LinkedResourceEntity toEntity() => LinkedResourceEntity(
    id: id,
    type: type,
    permissionLevel: PermissionLevel.fromValue(permissionLevel),
  );
}

extension LinkedResourceEntityMapper on LinkedResourceEntity {
  LinkedResourceDto toDto() => LinkedResourceDto(
    id: id,
    type: type,
    permissionLevel: permissionLevel.value,
  );
}
