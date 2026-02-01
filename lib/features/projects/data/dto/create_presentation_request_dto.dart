import 'package:AIPrimary/features/generate/data/dto/slide_theme_dto.dart';
import 'package:AIPrimary/features/projects/data/dto/slide_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_presentation_request_dto.g.dart';

/// DTO for creating a new presentation.
/// This matches the backend's CreatePresentationRequest type which omits
/// id, createdAt, and updatedAt fields.
@JsonSerializable(explicitToJson: true)
class CreatePresentationRequestDto {
  String title;
  @JsonKey(defaultValue: [])
  List<SlideDto> slides;
  @JsonKey(defaultValue: false)
  bool isParsed;
  @JsonKey(defaultValue: {'width': 1000.0, 'height': 562.5})
  Map<String, double> viewport;
  SlideThemeDto? theme;

  CreatePresentationRequestDto({
    required this.title,
    required this.slides,
    required this.isParsed,
    required this.viewport,
    this.theme,
  });

  factory CreatePresentationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePresentationRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePresentationRequestDtoToJson(this);
}
