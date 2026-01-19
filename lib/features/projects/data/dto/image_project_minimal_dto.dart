import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:json_annotation/json_annotation.dart';

part 'image_project_minimal_dto.g.dart';

@JsonSerializable()
class ImageProjectMinimalDto {
  final int id;
  final String originalFilename;
  final String url;
  final String? createdAt;
  final String? updatedAt;

  ImageProjectMinimalDto({
    required this.id,
    required this.originalFilename,
    required this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory ImageProjectMinimalDto.fromJson(Map<String, dynamic> json) =>
      _$ImageProjectMinimalDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImageProjectMinimalDtoToJson(this);
}

extension ImageProjectMinimalMapper on ImageProjectMinimalDto {
  ImageProjectMinimal toEntity() => ImageProjectMinimal(
    id: id.toString(),
    title: originalFilename, // Map originalFilename to title for UI
    url: url, // Map url to imageUrl for UI
    createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
  );
}

extension ImageProjectMinimalEntityMapper on ImageProjectMinimal {
  ImageProjectMinimalDto toDto() => ImageProjectMinimalDto(
    id: int.parse(id),
    originalFilename: title,
    url: url,
    createdAt: createdAt?.toIso8601String(),
    updatedAt: updatedAt?.toIso8601String(),
  );
}
