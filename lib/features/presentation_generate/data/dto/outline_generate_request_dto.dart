import 'package:json_annotation/json_annotation.dart';

part 'outline_generate_request_dto.g.dart';

@JsonSerializable()
class OutlineGenerateRequest {
  final String topic;
  @JsonKey(name: 'slide_count')
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
}
