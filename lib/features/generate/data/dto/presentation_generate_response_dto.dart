import 'package:json_annotation/json_annotation.dart';

part 'presentation_generate_response_dto.g.dart';

@JsonSerializable()
class PresentationGenerateResponse {
  final String id;
  final String title;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const PresentationGenerateResponse({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  factory PresentationGenerateResponse.fromJson(Map<String, dynamic> json) =>
      _$PresentationGenerateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationGenerateResponseToJson(this);
}
