import 'package:datn_mobile/features/generate/domain/entities/generation_result.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'outline_generate_response.g.dart';

/// Response DTO for POST /presentations/outline-generate endpoint
/// Contains the generated presentation outline in markdown format
@JsonSerializable()
class OutlineGenerateResponse {
  final String outline; // Markdown outline

  OutlineGenerateResponse({required this.outline});

  factory OutlineGenerateResponse.fromJson(Map<String, dynamic> json) =>
      _$OutlineGenerateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OutlineGenerateResponseToJson(this);
}

/// Extension to convert DTO to domain entity
extension OutlineGenerateResponseMapper on OutlineGenerateResponse {
  GenerationResult toEntity({required ResourceType resourceType}) {
    return GenerationResult(
      content: outline,
      generatedAt: DateTime.now(),
      resourceType: resourceType,
      usedPrompt: outline,
    );
  }
}
