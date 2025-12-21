import 'package:datn_mobile/features/projects/domain/entity/image_project.dart';
import 'package:json_annotation/json_annotation.dart';

part 'image_project_dto.g.dart';

@JsonSerializable()
class ImageProjectDto {
  String id;
  String title;
  String imageUrl;
  DateTime createdAt;
  DateTime updatedAt;
  String? description;

  ImageProjectDto({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory ImageProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ImageProjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImageProjectDtoToJson(this);
}

extension ImageProjectMapper on ImageProjectDto {
  ImageProject toEntity() => ImageProject(
    id: id,
    title: title,
    imageUrl: imageUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
    description: description,
  );
}

extension ImageProjectEntityMapper on ImageProject {
  ImageProjectDto toDto() => ImageProjectDto(
    id: id,
    title: title,
    imageUrl: imageUrl,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: description,
  );
}
