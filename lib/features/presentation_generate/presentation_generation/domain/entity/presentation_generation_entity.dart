class PresentationGenerationRequest {
  final String outline; // The outline generated in stage 1
  final String model;
  final String theme;
  final String? avoid;

  PresentationGenerationRequest({
    required this.outline,
    required this.model,
    required this.theme,
    this.avoid,
  });

  PresentationGenerationRequest copyWith({
    String? outline,
    String? model,
    String? theme,
    String? avoid,
  }) {
    return PresentationGenerationRequest(
      outline: outline ?? this.outline,
      model: model ?? this.model,
      theme: theme ?? this.theme,
      avoid: avoid ?? this.avoid,
    );
  }
}

class PresentationGenerationResponse {
  final String? id;
  final String? title;
  final String? content;
  final List<String>? slides; // URLs to generated slides
  final DateTime? createdAt;

  PresentationGenerationResponse({
    this.id,
    this.title,
    this.content,
    this.slides,
    this.createdAt,
  });

  PresentationGenerationResponse copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? slides,
    DateTime? createdAt,
  }) {
    return PresentationGenerationResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      slides: slides ?? this.slides,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
