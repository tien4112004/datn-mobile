import 'package:json_annotation/json_annotation.dart';

part 'outline_generate_request_dto.g.dart';

@JsonSerializable()
class OutlineGenerateRequest {
  final String topic;
  final int slideCount;
  final String language;
  final String model;
  final String provider;

  /// The grade level for the content (max 50 chars)
  final String? grade;

  /// The subject area for the content (max 100 chars)
  final String? subject;

  /// File URLs to use as source material for generation
  final List<String>? fileUrls;

  const OutlineGenerateRequest({
    required this.topic,
    required this.slideCount,
    required this.language,
    required this.model,
    required this.provider,
    this.grade,
    this.subject,
    this.fileUrls,
  });

  factory OutlineGenerateRequest.fromJson(Map<String, dynamic> json) =>
      _$OutlineGenerateRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$OutlineGenerateRequestToJson(this);
    json.removeWhere((key, value) => value == null);
    return json;
  }

  OutlineGenerateRequest copyWith({
    String? topic,
    int? slideCount,
    String? language,
    String? model,
    String? provider,
    String? grade,
    String? subject,
    List<String>? fileUrls,
  }) {
    return OutlineGenerateRequest(
      topic: topic ?? this.topic,
      slideCount: slideCount ?? this.slideCount,
      language: language ?? this.language,
      model: model ?? this.model,
      provider: provider ?? this.provider,
      grade: grade ?? this.grade,
      subject: subject ?? this.subject,
      fileUrls: fileUrls ?? this.fileUrls,
    );
  }
}
