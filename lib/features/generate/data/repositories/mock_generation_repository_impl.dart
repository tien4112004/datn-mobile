import 'package:datn_mobile/features/generate/domain/entities/generation_config.dart';
import 'package:datn_mobile/features/generate/domain/entities/generation_result.dart';
import 'package:datn_mobile/features/generate/domain/repositories/generation_repository.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';

/// Mock implementation of GenerationRepository for Phase 1 testing
/// Returns mock generated content for development
class MockGenerationRepositoryImpl implements GenerationRepository {
  @override
  Future<GenerationResult> generate(GenerationConfig config) async {
    // Simulate API delay (2 seconds for generation)
    await Future.delayed(const Duration(seconds: 2));

    final mockContent = _generateMockContent(config);

    return GenerationResult(
      content: mockContent,
      generatedAt: DateTime.now(),
      resourceType: config.resourceType,
    );
  }

  @override
  Stream<String> generateStream(GenerationConfig config) async* {
    // Simulate streaming by yielding content in chunks
    final fullContent = _generateMockContent(config);
    final words = fullContent.split(' ');

    for (final word in words) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield '$word ';
    }
  }

  /// Generate mock content based on resource type and config
  String _generateMockContent(GenerationConfig config) {
    switch (config.resourceType) {
      case ResourceType.presentation:
        return _generateMockPresentationOutline(config);
      case ResourceType.image:
        return _generateMockImageUrl(config);
      case ResourceType.mindmap:
        return _generateMockMindmapJson(config);
      default:
        return 'Unsupported resource type for mock generation.';
    }
  }

  /// Generate mock presentation outline in markdown
  String _generateMockPresentationOutline(GenerationConfig config) {
    final slideCount = config.slideCount ?? 10;
    final grade = config.grade ?? 5;
    final gradeLabel = 'Grade $grade';

    final slides = List.generate(
      slideCount,
      (i) =>
          '''
## Slide ${i + 1}
- Point about "${config.description}"
- Supporting detail ${i + 1}
- Key takeaway for $gradeLabel students
''',
    ).join('\n');

    return '''# ${config.description}

**Generated with ${config.model.displayName}**
**Target Grade: $gradeLabel**
**Slides: $slideCount**

## Introduction
This presentation covers the fascinating topic of "${config.description}".

---

$slides

---

## Conclusion
Thank you for learning about ${config.description}!
''';
  }

  /// Generate mock image URL (would be a real URL from API in Phase 2)
  String _generateMockImageUrl(GenerationConfig config) {
    return 'https://via.placeholder.com/1024x768?text=${Uri.encodeComponent(config.description)}';
  }

  /// Generate mock mindmap JSON (simplified structure)
  String _generateMockMindmapJson(GenerationConfig config) {
    return '''{
  "root": {
    "title": "${config.description}",
    "children": [
      {
        "title": "Topic 1",
        "children": [
          {"title": "Detail 1.1"},
          {"title": "Detail 1.2"}
        ]
      },
      {
        "title": "Topic 2",
        "children": [
          {"title": "Detail 2.1"},
          {"title": "Detail 2.2"}
        ]
      },
      {
        "title": "Topic 3",
        "children": [
          {"title": "Detail 3.1"},
          {"title": "Detail 3.2"}
        ]
      }
    ]
  }
}''';
  }
}
