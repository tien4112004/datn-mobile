import 'package:AIPrimary/features/projects/domain/entity/value_object/slide.dart';
import 'package:AIPrimary/features/projects/domain/entity/value_object/slide_background.dart';
import 'package:json_annotation/json_annotation.dart';

part 'slide_dto.g.dart';

@JsonSerializable()
class SlideDto {
  final String id;
  // final List<SlideElement> elements;
  // final SlideBackground background;

  SlideDto({
    required this.id,
    // required this.elements,
    // required this.background,
  });

  factory SlideDto.fromJson(Map<String, dynamic> json) =>
      _$SlideDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SlideDtoToJson(this);
}

extension SlideMapper on SlideDto {
  Slide toEntity() {
    return Slide(
      id: id,
      elements: [],
      background: SlideBackground(type: "solidColor", color: "0xFFFFFFFF"),
    );
  }
}

extension SlideDtoMapper on Slide {
  SlideDto toDto() {
    return SlideDto(
      id: id,
      // elements: [],
      // background: background,
    );
  }
}
