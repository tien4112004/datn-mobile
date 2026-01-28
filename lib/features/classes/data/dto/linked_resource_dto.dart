import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:datn_mobile/features/classes/domain/entity/permission_level.dart';

part 'linked_resource_dto.g.dart';

@JsonSerializable()
class LinkedResourceDto {
  final String id;
  final String type;
  final String permissionLevel;
  final String?
  title; // Enriched by backend (optional for backward compatibility)
  final String?
  thumbnail; // Enriched by backend (optional, null for assignments)

  const LinkedResourceDto({
    required this.id,
    required this.type,
    required this.permissionLevel,
    this.title,
    this.thumbnail,
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
    title: title,
    thumbnail: thumbnail,
  );
}

extension LinkedResourceEntityMapper on LinkedResourceEntity {
  LinkedResourceDto toDto() => LinkedResourceDto(
    id: id,
    type: type,
    permissionLevel: permissionLevel.value,
  );
}
