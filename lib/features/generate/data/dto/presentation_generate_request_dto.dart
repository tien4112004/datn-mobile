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

  /// The grade level for the content (max 50 chars)
  final String? grade;

  /// The subject area for the content (max 100 chars)
  final String? subject;

  /// File URLs that were used during outline generation
  final List<String>? fileUrls;

  const PresentationGenerateRequest({
    required this.model,
    required this.provider,
    required this.language,
    required this.slideCount,
    required this.outline,
    this.presentation,
    this.others,
    this.grade,
    this.subject,
    this.fileUrls,
  });

  factory PresentationGenerateRequest.fromJson(Map<String, dynamic> json) =>
      _$PresentationGenerateRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$PresentationGenerateRequestToJson(this);
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
