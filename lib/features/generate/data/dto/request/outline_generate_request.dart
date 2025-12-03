import 'package:datn_mobile/features/generate/domain/entities/generation_config.dart';
import 'package:json_annotation/json_annotation.dart';

part 'outline_generate_request.g.dart';

/// Request DTO for POST /presentations/outline-generate endpoint
/// Used specifically for presentation generation
@JsonSerializable()
class OutlineGenerateRequest {
  final String topic; // User's description/prompt
  final int slideCount; // Number of slides (1-35)
  final String model; // AI model name (e.g., "gpt-4", "claude-3")
  final String language; // Language code (e.g., "English", "Spanish")
  final String provider; // AI provider (e.g., "openai", "anthropic")
  @JsonKey(name: 'learning_objective')
  final String? learningObjective; // Optional learning objective
  @JsonKey(name: 'target_age')
  final String targetAge; // "7-10", "6-12", "Primary students"

  OutlineGenerateRequest({
    required this.provider,
    required this.topic,
    required this.slideCount,
    required this.model,
    this.language = 'English',
    this.learningObjective,
    required this.targetAge,
  });

  factory OutlineGenerateRequest.fromJson(Map<String, dynamic> json) =>
      _$OutlineGenerateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OutlineGenerateRequestToJson(this);
}

/// Extension to convert GenerationConfig to OutlineGenerateRequest
extension GenerationConfigToPresentationRequest on GenerationConfig {
  OutlineGenerateRequest toOutlineRequest() {
    return OutlineGenerateRequest(
      topic: description,
      slideCount: slideCount ?? 10,
      model: model.name,
      language: 'English',
      learningObjective: avoidContent != null ? description : null,
      targetAge: targetAge,
      provider: model.provider.toLowerCase(),
    );
  }
}
