import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/enum/presentation_theme.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

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

  /// Whether education mode is enabled
  final bool isEducationMode;

  /// Typed grade level for education mode UI
  final GradeLevel? gradeLevel;

  /// Typed subject for education mode UI
  final Subject? subjectEnum;

  /// Selected chapter name for education mode
  final String? chapter;

  /// File URLs to use as source material for generation
  final List<String> fileUrls;

  /// File sizes in bytes keyed by CDN URL, used to enforce total size limits
  final Map<String, int> fileSizes;

  static const int maxTotalBytes = 10 * 1000 * 1000; // 10 MB (SI)

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
    this.isEducationMode = false,
    this.gradeLevel,
    this.subjectEnum,
    this.chapter,
    this.fileUrls = const [],
    this.fileSizes = const {},
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
    bool? isEducationMode,
    GradeLevel? gradeLevel,
    bool clearGradeLevel = false,
    Subject? subjectEnum,
    bool clearSubjectEnum = false,
    String? chapter,
    bool clearChapter = false,
    List<String>? fileUrls,
    Map<String, int>? fileSizes,
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
      isEducationMode: isEducationMode ?? this.isEducationMode,
      gradeLevel: clearGradeLevel ? null : (gradeLevel ?? this.gradeLevel),
      subjectEnum: clearSubjectEnum ? null : (subjectEnum ?? this.subjectEnum),
      chapter: clearChapter ? null : (chapter ?? this.chapter),
      fileUrls: fileUrls ?? this.fileUrls,
      fileSizes: fileSizes ?? this.fileSizes,
    );
  }

  int get totalAttachedBytes => fileSizes.values.fold(0, (a, b) => a + b);

  bool get hasContent => topic.trim().isNotEmpty || fileUrls.isNotEmpty;
  bool get isEducationModeValid =>
      !isEducationMode ||
      (gradeLevel != null && subjectEnum != null && chapter != null);
  bool get isValid => hasContent && isEducationModeValid;
  bool get isStep1Valid => hasContent && isEducationModeValid;
  bool get isStep2Valid => outline.isNotEmpty;
}
