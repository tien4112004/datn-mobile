import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';

/// Domain entity representing the configuration for content generation
/// Supports multiple resource types (presentation, image, mindmap)
/// Options are resource-specific and stored in a flexible map
class GenerationConfig {
  final ResourceType resourceType; // presentation, image, mindmap
  final AIModel model; // From backend API
  final String description; // User's description/prompt
  final Map<String, dynamic> options; // Resource-specific options

  const GenerationConfig({
    required this.resourceType,
    required this.model,
    required this.description,
    this.options = const {},
  });

  /// Presentation-specific helpers
  int? get slideCount => options['slideCount'] as int?;
  int? get grade => options['grade'] as int?;
  String? get theme => options['theme'] as String?;
  String? get avoidContent => options['avoidContent'] as String?;

  /// Convert grade number to API targetAge format for presentation
  String get targetAge {
    final gradeValue = grade ?? 5;
    switch (gradeValue) {
      case 1:
      case 2:
        return '7-10';
      case 3:
      case 4:
        return '6-12';
      case 5:
      default:
        return 'Primary students';
    }
  }

  /// Validate configuration before submission
  bool get isValid {
    if (description.trim().isEmpty) return false;

    // Resource-specific validation
    switch (resourceType) {
      case ResourceType.presentation:
        return slideCount != null && slideCount! > 0 && slideCount! <= 50;
      case ResourceType.image:
        // Image generation doesn't need additional options
        return true;
      case ResourceType.mindmap:
        // Mindmap generation doesn't need additional options
        return true;
      default:
        return false;
    }
  }

  GenerationConfig copyWith({
    ResourceType? resourceType,
    AIModel? model,
    String? description,
    Map<String, dynamic>? options,
  }) {
    return GenerationConfig(
      resourceType: resourceType ?? this.resourceType,
      model: model ?? this.model,
      description: description ?? this.description,
      options: options ?? this.options,
    );
  }

  factory GenerationConfig.empty({
    required ResourceType resourceType,
    required AIModel model,
  }) {
    return GenerationConfig(
      resourceType: resourceType,
      model: model,
      description: '',
      options: {},
    );
  }

  @override
  String toString() =>
      'GenerationConfig(resourceType: $resourceType, model: ${model.displayName}, description: ${description.substring(0, 30)}...)';
}
