import 'package:datn_mobile/shared/models/model_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'outline_generate_request_dto.g.dart';

class _ModelInfoConverter
    implements JsonConverter<ModelInfo, Map<String, dynamic>> {
  const _ModelInfoConverter();

  @override
  ModelInfo fromJson(Map<String, dynamic> json) => ModelInfo.fromJson(json);

  @override
  Map<String, dynamic> toJson(ModelInfo object) => object.toJson();
}

@JsonSerializable()
class OutlineGenerateRequest {
  final String topic;
  @JsonKey(name: 'slide_count')
  final int slideCount;
  final String language;
  @_ModelInfoConverter()
  final ModelInfo model;

  const OutlineGenerateRequest({
    required this.topic,
    required this.slideCount,
    required this.language,
    required this.model,
  });

  factory OutlineGenerateRequest.fromJson(Map<String, dynamic> json) =>
      _$OutlineGenerateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OutlineGenerateRequestToJson(this);
}
