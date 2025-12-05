import 'package:datn_mobile/features/projects/enum/resource_type.dart';

/// Domain entity representing the result of content generation
/// Can represent markdown outline, image URL, mindmap data, etc.
class GenerationResult {
  final String usedPrompt;
  // Depending on resourceType, in specific contexts, this `content` should be parsed differently.
  final String content; // Markdown outline, image URL, mindmap JSON, etc.
  final DateTime generatedAt;
  final ResourceType resourceType;

  const GenerationResult({
    required this.usedPrompt,
    required this.content,
    required this.generatedAt,
    required this.resourceType,
  });

  bool get isEmpty => content.trim().isEmpty;

  GenerationResult copyWith({
    String? content,
    DateTime? generatedAt,
    ResourceType? resourceType,
    String? usedPrompt,
  }) {
    return GenerationResult(
      usedPrompt: usedPrompt ?? this.usedPrompt,
      content: content ?? this.content,
      generatedAt: generatedAt ?? this.generatedAt,
      resourceType: resourceType ?? this.resourceType,
    );
  }
}
