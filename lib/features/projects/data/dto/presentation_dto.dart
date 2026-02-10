import 'package:AIPrimary/features/projects/data/dto/slide_dto.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presentation_dto.g.dart';

@JsonSerializable(createFactory: false)
class PresentationDto {
  @JsonKey(defaultValue: '')
  String id;
  @JsonKey(defaultValue: '')
  String title;
  @JsonKey(defaultValue: {})
  Object metaData;
  @JsonKey(defaultValue: [])
  List<SlideDto> slides;
  DateTime createdAt;
  DateTime updatedAt;
  @JsonKey(name: 'parsed', defaultValue: false)
  bool isParsed;
  @JsonKey(defaultValue: {'width': 1000.0, 'height': 562.5})
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

  factory PresentationDto.fromJson(Map<String, dynamic> json) {
    // Handle nullable DateTime fields with fallback to current time
    final createdAtStr = json['createdAt'] as String?;
    final updatedAtStr = json['updatedAt'] as String?;
    final now = DateTime.now();

    return PresentationDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      metaData: json['metaData'] as Object? ?? {},
      slides:
          (json['slides'] as List<dynamic>?)
              ?.map((e) => SlideDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: createdAtStr != null ? DateTime.parse(createdAtStr).toLocal() : now,
      updatedAt: updatedAtStr != null ? DateTime.parse(updatedAtStr).toLocal() : now,
      isParsed: json['parsed'] as bool? ?? json['isParsed'] as bool? ?? false,
      viewport:
          (json['viewport'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          {'width': 1000.0, 'height': 562.5},
    );
  }

  Map<String, dynamic> toJson() => _$PresentationDtoToJson(this);

  /// Creates a JSON map suitable for the create presentation API request.
  /// Omits id, createdAt, updatedAt, and metaData as these are either
  /// assigned by backend or not part of CreatePresentationRequest.
  Map<String, dynamic> toCreateJson() => {
    'title': title,
    'slides': slides.map((e) => e.toJson()).toList(),
    'isParsed': isParsed,
    'viewport': viewport,
  };
}

extension PresentationMapper on PresentationDto {
  Presentation toEntity() => Presentation(
    id: id,
    title: title,
    createdAt: createdAt.toLocal(),
    updatedAt: updatedAt.toLocal(),
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
