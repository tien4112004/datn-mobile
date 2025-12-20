import 'package:json_annotation/json_annotation.dart';

part 'presentation_generate_request_dto.g.dart';

@JsonSerializable()
class PresentationGenerateRequest {
  /// The model to use for generation
  final String model;

  /// The provider of the model
  final String provider;

  /// The language for the presentation
  final String language;

  /// The number of slides to generate
  final int slideCount;

  /// The outline for the presentation
  final String outline;

  /// Additional metadata for the presentation (theme and viewport)
  final Map<String, dynamic>? presentation;

  /// Other configuration options
  final Map<String, dynamic>? others;

  const PresentationGenerateRequest({
    required this.model,
    required this.provider,
    required this.language,
    required this.slideCount,
    required this.outline,
    this.presentation,
    this.others,
  });

  factory PresentationGenerateRequest.fromJson(Map<String, dynamic> json) =>
      _$PresentationGenerateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationGenerateRequestToJson(this);
}
