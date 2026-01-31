import 'package:AIPrimary/features/projects/domain/entity/presentation.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presentation_dto.g.dart';

@JsonSerializable()
class PresentationDto {
  String id;
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  String? thumbnail;

  PresentationDto({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnail,
  });

  factory PresentationDto.fromJson(Map<String, dynamic> json) =>
      _$PresentationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationDtoToJson(this);
}

extension PresentationMapper on PresentationDto {
  Presentation toEntity() => Presentation(
    id: id,
    title: title,
    createdAt: createdAt,
    updatedAt: updatedAt,
    thumbnail: thumbnail,
    deletedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

extension PresentationEntityMapper on Presentation {
  PresentationDto toDto() => PresentationDto(
    id: id,
    title: title,
    createdAt: DateFormatHelper.getNow(),
    updatedAt: DateFormatHelper.getNow(),
    thumbnail: thumbnail,
  );
}
