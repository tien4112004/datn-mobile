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

  const GeneratedImage({this.url, this.mimeType, this.prompt, this.created});

  GeneratedImage copyWith({
    String? url,
    String? mimeType,
    String? prompt,
    String? created,
  }) {
    return GeneratedImage(
      url: url ?? this.url,
      mimeType: mimeType ?? this.mimeType,
      prompt: prompt ?? this.prompt,
      created: created ?? this.created,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'mimeType': mimeType,
    'prompt': prompt,
    'created': created,
  };

  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      url: json['url'] as String?,
      mimeType: json['mimeType'] as String?,
      prompt: json['prompt'] as String?,
      created: json['created'] as String?,
    );
  }

  @override
  String toString() {
    return 'GeneratedImage(url: $url, mimeType: $mimeType, prompt: $prompt, created: $created)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeneratedImage &&
        other.url == url &&
        other.mimeType == mimeType &&
        other.prompt == prompt &&
        other.created == created;
  }

  @override
  int get hashCode =>
      url.hashCode ^ mimeType.hashCode ^ prompt.hashCode ^ created.hashCode;
}
