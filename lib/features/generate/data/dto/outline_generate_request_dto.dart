import 'package:json_annotation/json_annotation.dart';

part 'outline_generate_request_dto.g.dart';

@JsonSerializable()
class OutlineGenerateRequest {
  final String topic;
  final int slideCount;
  final String language;
  final String model;
  final String provider;

  const OutlineGenerateRequest({
    required this.topic,
    required this.slideCount,
    required this.language,
    required this.model,
    required this.provider,
  });

  factory OutlineGenerateRequest.fromJson(Map<String, dynamic> json) =>
      _$OutlineGenerateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OutlineGenerateRequestToJson(this);

  OutlineGenerateRequest copyWith({
    String? topic,
    int? slideCount,
    String? language,
    String? model,
    String? provider,
  }) {
    return OutlineGenerateRequest(
      topic: topic ?? this.topic,
      slideCount: slideCount ?? this.slideCount,
      language: language ?? this.language,
      model: model ?? this.model,
      provider: provider ?? this.provider,
    );
  }
}
