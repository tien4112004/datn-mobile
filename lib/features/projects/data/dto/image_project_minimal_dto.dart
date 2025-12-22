import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:json_annotation/json_annotation.dart';

part 'image_project_minimal_dto.g.dart';

@JsonSerializable()
class ImageProjectMinimalDto {
  String id;
  String title;
  String imageUrl;
  DateTime createdAt;
  DateTime updatedAt;

  ImageProjectMinimalDto({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ImageProjectMinimalDto.fromJson(Map<String, dynamic> json) =>
      _$ImageProjectMinimalDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImageProjectMinimalDtoToJson(this);
}

extension ImageProjectMinimalMapper on ImageProjectMinimalDto {
  ImageProjectMinimal toEntity() => ImageProjectMinimal(
    id: id,
    title: title,
    imageUrl: imageUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension ImageProjectMinimalEntityMapper on ImageProjectMinimal {
  ImageProjectMinimalDto toDto() => ImageProjectMinimalDto(
    id: id,
    title: title,
    imageUrl: imageUrl,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
  );
}
