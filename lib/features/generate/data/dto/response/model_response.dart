import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_response.g.dart';

/// Response DTO for /models API endpoint
/// Represents an AI model returned by the backend
@JsonSerializable()
class ModelResponse {
  @JsonKey(name: 'modelId')
  final String id;
  final String modelName; // e.g., "gpt-4", "claude-3"
  final String displayName; // e.g., "GPT-4", "Claude 3"
  final String modelType; // "TEXT" or "IMAGE"
  final String provider; // "openai", "anthropic", etc.
  @JsonKey(name: 'default')
  final bool isDefault;
  @JsonKey(name: 'enabled')
  final bool isEnabled;

  ModelResponse({
    required this.id,
    required this.provider,
    required this.modelName,
    required this.displayName,
    required this.modelType,
    required this.isDefault,
    required this.isEnabled,
  });

  factory ModelResponse.fromJson(Map<String, dynamic> json) =>
      _$ModelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ModelResponseToJson(this);
}

/// Extension to convert DTO to domain entity
extension ModelResponseMapper on ModelResponse {
  AIModel toEntity() {
    return AIModel(
      id: int.parse(id),
      provider: provider,
      name: modelName,
      displayName: displayName,
      type: ModelType.fromValue(modelType),
      isDefault: isDefault,
      isEnabled: isEnabled,
    );
  }
}
