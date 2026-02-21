import 'package:AIPrimary/features/projects/domain/entity/image_project.dart';
import 'package:json_annotation/json_annotation.dart';

part 'image_project_dto.g.dart';

@JsonSerializable()
class ImageProjectDto {
  final int id;
  final String originalFilename;
  final String url;
  final String mediaType;
  final int fileSize;
  final String createdAt;
  final String updatedAt;

  ImageProjectDto({
    required this.id,
    required this.originalFilename,
    required this.url,
    required this.mediaType,
    required this.fileSize,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ImageProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ImageProjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImageProjectDtoToJson(this);
}

extension ImageProjectMapper on ImageProjectDto {
  ImageProject toEntity() => ImageProject(
    id: id.toString(),
    title: originalFilename, // Map originalFilename to title for UI
    imageUrl: url, // Map url to imageUrl for UI
    mediaType: mediaType,
    fileSize: fileSize,
    createdAt: DateTime.parse(createdAt).toLocal(),
    updatedAt: DateTime.parse(updatedAt).toLocal(),
    description: null, // Not provided by API
  );
}

extension ImageProjectEntityMapper on ImageProject {
  ImageProjectDto toDto() => ImageProjectDto(
    id: int.parse(id),
    originalFilename: title,
    url: imageUrl,
    mediaType: mediaType ?? 'IMAGE_JPEG',
    fileSize: fileSize ?? 0,
    createdAt: createdAt.toIso8601String(),
    updatedAt: updatedAt.toIso8601String(),
  );
}
