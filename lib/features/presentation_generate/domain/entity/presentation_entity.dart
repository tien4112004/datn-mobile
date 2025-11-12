import 'package:datn_mobile/features/presentation_generate/enum/presentation_enums.dart';

class PresentationRequest {
  final PresentationModel model;
  final PresentationGrade grade;
  final PresentationTheme theme;
  final int? slides;
  final String description;
  final String? avoid;
  final List<String>? attachments; // URLs or file paths

  PresentationRequest({
    required this.model,
    required this.grade,
    required this.theme,
    this.slides,
    required this.description,
    this.avoid,
    this.attachments,
  });

  PresentationRequest copyWith({
    PresentationModel? model,
    PresentationGrade? grade,
    PresentationTheme? theme,
    int? slides,
    String? description,
    String? avoid,
    List<String>? attachments,
  }) {
    return PresentationRequest(
      model: model ?? this.model,
      grade: grade ?? this.grade,
      theme: theme ?? this.theme,
      slides: slides ?? this.slides,
      description: description ?? this.description,
      avoid: avoid ?? this.avoid,
      attachments: attachments ?? this.attachments,
    );
  }
}

class PresentationResponse {
  final String? id;
  final String? title;
  final String? content;
  final List<String>? slides; // URLs to generated slides
  final DateTime? createdAt;

  PresentationResponse({
    this.id,
    this.title,
    this.content,
    this.slides,
    this.createdAt,
  });

  PresentationResponse copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? slides,
    DateTime? createdAt,
  }) {
    return PresentationResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      slides: slides ?? this.slides,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}