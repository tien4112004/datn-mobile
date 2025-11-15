class OutlineRequest {
  final String topic;
  final String language;
  final String model;
  final int slideCount;
  final String provider;

  OutlineRequest({
    required this.topic,
    required this.language,
    required this.model,
    required this.slideCount,
    required this.provider,
  });

  OutlineRequest copyWith({
    String? topic,
    String? language,
    String? model,
    int? slideCount,
    String? provider,
  }) {
    return OutlineRequest(
      topic: topic ?? this.topic,
      language: language ?? this.language,
      model: model ?? this.model,
      slideCount: slideCount ?? this.slideCount,
      provider: provider ?? this.provider,
    );
  }
}

class OutlineResponse {
  final String? id;
  final String? content; // The generated outline text
  final DateTime? createdAt;

  OutlineResponse({this.id, this.content, this.createdAt});

  OutlineResponse copyWith({String? id, String? content, DateTime? createdAt}) {
    return OutlineResponse(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
