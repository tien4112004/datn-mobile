import 'package:datn_mobile/features/projects/enum/resource_type.dart';

/// Domain entity representing the result of content generation
/// Can represent markdown outline, image URL, mindmap data, etc.
class GenerationResult {
  final String content; // Markdown outline, image URL, mindmap JSON, etc.
  final DateTime generatedAt;
  final ResourceType resourceType;

  const GenerationResult({
    required this.content,
    required this.generatedAt,
    required this.resourceType,
  });

  bool get isEmpty => content.trim().isEmpty;

  GenerationResult copyWith({
    String? content,
    DateTime? generatedAt,
    ResourceType? resourceType,
  }) {
    return GenerationResult(
      content: content ?? this.content,
      generatedAt: generatedAt ?? this.generatedAt,
      resourceType: resourceType ?? this.resourceType,
    );
  }
}
