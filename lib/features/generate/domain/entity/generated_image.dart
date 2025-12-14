/// Entity representing a generated image.
class GeneratedImage {
  /// The URI/URL of the generated image
  final String? url;

  /// The MIME type of the generated image (e.g., image/png)
  final String? mimeType;

  /// The prompt used to generate the image
  final String? prompt;

  /// The timestamp when the image was created
  final String? created;

  /// The AI model used to generate the image
  final String? model;

  /// The aspect ratio of the generated image
  final String? aspectRatio;

  const GeneratedImage({
    this.url,
    this.mimeType,
    this.prompt,
    this.created,
    this.model,
    this.aspectRatio,
  });

  GeneratedImage copyWith({
    String? url,
    String? mimeType,
    String? prompt,
    String? created,
    String? model,
    String? aspectRatio,
  }) {
    return GeneratedImage(
      url: url ?? this.url,
      mimeType: mimeType ?? this.mimeType,
      prompt: prompt ?? this.prompt,
      created: created ?? this.created,
      model: model ?? this.model,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'mimeType': mimeType,
    'prompt': prompt,
    'created': created,
    'model': model,
    'aspectRatio': aspectRatio,
  };

  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      url: json['url'] as String?,
      mimeType: json['mimeType'] as String?,
      prompt: json['prompt'] as String?,
      created: json['created'] as String?,
      model: json['model'] as String?,
      aspectRatio: json['aspectRatio'] as String?,
    );
  }

  @override
  String toString() {
    return 'GeneratedImage(url: $url, mimeType: $mimeType, prompt: $prompt, created: $created, model: $model, aspectRatio: $aspectRatio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeneratedImage &&
        other.url == url &&
        other.mimeType == mimeType &&
        other.prompt == prompt &&
        other.created == created &&
        other.model == model &&
        other.aspectRatio == aspectRatio;
  }

  @override
  int get hashCode =>
      url.hashCode ^
      mimeType.hashCode ^
      prompt.hashCode ^
      created.hashCode ^
      model.hashCode ^
      aspectRatio.hashCode;
}
