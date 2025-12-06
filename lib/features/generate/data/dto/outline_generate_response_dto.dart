import 'package:json_annotation/json_annotation.dart';

part 'outline_generate_response_dto.g.dart';

@JsonSerializable()
class OutlineGenerateResponse {
  final String id;
  final String outline;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const OutlineGenerateResponse({
    required this.id,
    required this.outline,
    required this.createdAt,
  });

  factory OutlineGenerateResponse.fromJson(Map<String, dynamic> json) =>
      _$OutlineGenerateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OutlineGenerateResponseToJson(this);
}
