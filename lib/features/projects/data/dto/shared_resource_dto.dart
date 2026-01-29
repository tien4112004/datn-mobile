import 'package:datn_mobile/features/projects/domain/entity/shared_resource.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shared_resource_dto.g.dart';

@JsonSerializable()
class SharedResourceDto {
  final String id;
  final String type;
  final String title;
  final String permission;
  final String? thumbnailUrl;
  final String ownerId;
  final String ownerName;

  SharedResourceDto({
    required this.id,
    required this.type,
    required this.title,
    required this.permission,
    this.thumbnailUrl,
    required this.ownerId,
    required this.ownerName,
  });

  factory SharedResourceDto.fromJson(Map<String, dynamic> json) =>
      _$SharedResourceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SharedResourceDtoToJson(this);
}

extension SharedResourceDtoMapper on SharedResourceDto {
  SharedResource toEntity() {
    return SharedResource(
      id: id,
      type: type,
      title: title,
      permission: permission,
      thumbnailUrl: thumbnailUrl,
      ownerId: ownerId,
      ownerName: ownerName,
    );
  }
}

extension SharedResourceEntityMapper on SharedResource {
  SharedResourceDto toDto() {
    return SharedResourceDto(
      id: id,
      type: type,
      title: title,
      permission: permission,
      thumbnailUrl: thumbnailUrl,
      ownerId: ownerId,
      ownerName: ownerName,
    );
  }
}
