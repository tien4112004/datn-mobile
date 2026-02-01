import 'package:AIPrimary/features/projects/data/dto/slide_dto.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presentation_dto.g.dart';

@JsonSerializable()
class PresentationDto {
  String id;
  String title;
  Object metaData;
  List<SlideDto> slides;
  DateTime createdAt;
  DateTime updatedAt;
  bool isParsed;
  Map<String, double> viewport;

  PresentationDto({
    required this.id,
    required this.title,
    required this.metaData,
    required this.slides,
    required this.createdAt,
    required this.updatedAt,
    required this.isParsed,
    required this.viewport,
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
    isParsed: isParsed,
    slides: slides.map((e) => e.toEntity()).toList(),
    metaData: metaData,
    deletedAt: DateTime.fromMillisecondsSinceEpoch(0),
    viewport: viewport,
  );
}

extension PresentationEntityMapper on Presentation {
  PresentationDto toDto() => PresentationDto(
    id: id,
    title: title,
    metaData: {},
    slides: [],
    createdAt: DateFormatHelper.getNow(),
    updatedAt: DateFormatHelper.getNow(),
    isParsed: false,
    viewport: {'width': 1000, 'height': 562.5},
  );
}
