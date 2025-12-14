import 'package:datn_mobile/features/generate/data/dto/image_generation_request_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated_image.g.dart';

/// Entity representing a generated image.
@JsonSerializable()
class GeneratedImage {
  /// The URI/URL of the generated image
  final String url;

  /// The MIME type of the generated image (e.g., image/png)
  final String? mimeType;

  /// The prompt used to generate the image
  final String prompt;

  /// The art style for the generated image
  final String artStyle;

  /// Additional art description
  final String artDescription;

  /// Additional theme description
  final String themeDescription;

  /// The AI model used to generate the image
  final String model;

  /// The aspect ratio of the generated image
  final String aspectRatio;

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

  factory GeneratedImage.fromJson(Map<String, dynamic> json) =>
      _$GeneratedImageFromJson(json);

  factory GeneratedImage.fromRequestDto(ImageGenerationRequestDto request) {
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
