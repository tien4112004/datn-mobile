import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/enum/presentation_theme.dart';

/// State class representing the presentation generation form inputs.
class PresentationFormState {
  // Step 1: Outline Generation
  final String topic;
  final int slideCount;
  final String language;
  final AIModel? outlineModel;

  // Step 2: Presentation Customization
  final PresentationTheme theme;
  final String? themeId; // Theme ID from API
  final AIModel? imageModel;
  final String avoidContent;

  // Generated outline (populated after Step 1)
  final String outline;

  // Current step (1 or 2)
  final int currentStep;

  /// The grade level for the content (optional, max 50 chars)
  final String? grade;

  /// The subject area for the content (optional, max 100 chars)
  final String? subject;

  /// File URLs to use as source material for generation
  final List<String> fileUrls;

  const PresentationFormState({
    this.topic = '',
    this.slideCount = 5,
    this.language = 'en',
    this.outlineModel,
    this.theme = PresentationTheme.modern,
    this.themeId,
    this.imageModel,
    this.avoidContent = '',
    this.outline = '',
    this.currentStep = 1,
    this.grade,
    this.subject,
    this.fileUrls = const [],
  });

  PresentationFormState copyWith({
    String? topic,
    int? slideCount,
    String? language,
    AIModel? outlineModel,
    bool clearOutlineModel = false,
    PresentationTheme? theme,
    String? themeId,
    AIModel? imageModel,
    bool clearImageModel = false,
    String? avoidContent,
    String? outline,
    int? currentStep,
    String? grade,
    bool clearGrade = false,
    String? subject,
    bool clearSubject = false,
    List<String>? fileUrls,
  }) {
    return PresentationFormState(
      topic: topic ?? this.topic,
      slideCount: slideCount ?? this.slideCount,
      language: language ?? this.language,
      outlineModel: clearOutlineModel
          ? null
          : (outlineModel ?? this.outlineModel),
      theme: theme ?? this.theme,
      themeId: themeId ?? this.themeId,
      imageModel: clearImageModel ? null : (imageModel ?? this.imageModel),
      avoidContent: avoidContent ?? this.avoidContent,
      outline: outline ?? this.outline,
      currentStep: currentStep ?? this.currentStep,
      grade: clearGrade ? null : (grade ?? this.grade),
      subject: clearSubject ? null : (subject ?? this.subject),
      fileUrls: fileUrls ?? this.fileUrls,
    );
  }

  bool get isValid => topic.trim().isNotEmpty || fileUrls.isNotEmpty;
  bool get isStep1Valid => topic.trim().isNotEmpty || fileUrls.isNotEmpty;
  bool get isStep2Valid => outline.isNotEmpty;
}
