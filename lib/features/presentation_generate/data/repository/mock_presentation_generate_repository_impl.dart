part of 'repository_provider.dart';

class MockPresentationGenerateRepositoryImpl
    implements PresentationGenerateRepository {
  @override
  Future<OutlineGenerateResponse> generateOutline(
    OutlineGenerateRequest outlineData,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock outline response
    return OutlineGenerateResponse(
      id: 'mock-outline-${DateTime.now().millisecondsSinceEpoch}',
      outline: '''### ${outlineData.topic}

---

### Introduction
- Overview of the topic
- Importance and relevance
- Key objectives

---

### Main Content
- Point 1: Detailed explanation
- Point 2: Supporting evidence
- Point 3: Practical applications

---

### Conclusion
- Summary of key points
- Future implications
- Call to action

---
*Generated outline with ${outlineData.slideCount} slides in ${outlineData.language}*''',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<PresentationGenerateResponse> generatePresentation(
    PresentationGenerateRequest request,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock response
    return PresentationGenerateResponse(
      id: 'mock-presentation-${DateTime.now().millisecondsSinceEpoch}',
      title:
          'Generated: ${request.outline.substring(0, request.outline.length.clamp(0, 30))}...',
      status: 'completed',
      createdAt: DateTime.now(),
    );
  }
}
