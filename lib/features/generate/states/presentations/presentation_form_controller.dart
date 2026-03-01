part of '../controller_provider.dart';

/// Controller for managing the presentation form state.
///
/// State is explicitly kept alive to prevent loss during navigation
/// between the generation, customization, and editor pages.
class PresentationFormController extends Notifier<PresentationFormState> {
  @override
  PresentationFormState build() {
    // Load persisted preferences
    final prefs = ref.read(generationPreferencesServiceProvider);

    // Load language
    final savedLanguage = prefs.getPresentationLanguage();

    // Load text model (outline model)
    final savedTextModelId = prefs.getPresentationTextModelId();
    if (savedTextModelId != null) {
      ref.listen(modelsControllerPod(ModelType.text), (_, next) {
        next.whenData((state) {
          final model = state.availableModels
              .where((m) => m.id == savedTextModelId)
              .firstOrNull;
          if (model != null) {
            updateOutlineModel(model);
          }
        });
      });
    }

    final normalizedLanguage =
        (savedLanguage == 'vi' || savedLanguage == 'Vietnamese') ? 'vi' : 'en';
    return PresentationFormState(language: normalizedLanguage);
  }

  // Step 1 updates
  void updateTopic(String topic) {
    state = state.copyWith(topic: topic);
  }

  void updateSlideCount(int count) {
    state = state.copyWith(slideCount: count);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
    ref
        .read(generationPreferencesServiceProvider)
        .savePresentationLanguage(language);
  }

  void updateOutlineModel(AIModel model) {
    state = state.copyWith(outlineModel: model);
    ref
        .read(generationPreferencesServiceProvider)
        .savePresentationTextModelId(model.id);
  }

  // Step 2 updates
  void updateTheme(PresentationTheme theme) {
    state = state.copyWith(theme: theme);
  }

  void updateThemeId(String themeId) {
    state = state.copyWith(themeId: themeId);
    ref
        .read(generationPreferencesServiceProvider)
        .savePresentationThemeId(themeId);
  }

  void updateImageModel(AIModel model) {
    state = state.copyWith(imageModel: model);
    ref
        .read(generationPreferencesServiceProvider)
        .savePresentationImageModelId(model.id);
  }

  void updateAvoidContent(String content) {
    state = state.copyWith(avoidContent: content);
  }

  void updateGrade(String? grade) {
    state = state.copyWith(grade: grade, clearGrade: grade == null);
  }

  void updateSubject(String? subject) {
    state = state.copyWith(subject: subject, clearSubject: subject == null);
  }

  void addFile(String url, int bytes) {
    final updatedUrls = [...state.fileUrls, url];
    final updatedSizes = {...state.fileSizes, url: bytes};
    state = state.copyWith(fileUrls: updatedUrls, fileSizes: updatedSizes);
  }

  void removeFileUrl(String url) {
    final updatedUrls = state.fileUrls.where((u) => u != url).toList();
    final updatedSizes = {...state.fileSizes}..remove(url);
    state = state.copyWith(fileUrls: updatedUrls, fileSizes: updatedSizes);
  }

  // Outline management
  void setOutline(String outline) {
    state = state.copyWith(outline: outline, currentStep: 2);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void reset() {
    // Preserve preference-related fields, only clear user-input fields
    state = PresentationFormState(
      language: state.language,
      outlineModel: state.outlineModel,
      imageModel: state.imageModel,
      themeId: state.themeId,
      theme: state.theme,
      // User-input fields use defaults: topic='', slideCount=5, outline='', currentStep=1, fileUrls=[], etc.
    );
  }

  // Create outline data for Step 1
  OutlineGenerateRequest toOutlineData() {
    final outlineModel = state.outlineModel != null
        ? ModelInfo(
            name: state.outlineModel!.name,
            provider: state.outlineModel!.provider,
          )
        : ModelInfo.getDefault();

    return OutlineGenerateRequest(
      topic: state.topic,
      slideCount: state.slideCount,
      language: state.language,
      model: outlineModel.name,
      provider: outlineModel.provider,
      grade: state.grade,
      subject: state.subject,
      fileUrls: state.fileUrls.isNotEmpty ? state.fileUrls : null,
    );
  }

  // Create presentation request for Step 2
  PresentationGenerateRequest toPresentationRequest() {
    final outlineModel = state.outlineModel;
    final imageModel = state.imageModel;
    final themeId = state.themeId;

    if (themeId == null) {
      throw const FormatException('Please select a presentation theme');
    }

    if (imageModel == null) {
      throw const FormatException('Please select an image model');
    }

    // Get the full theme object from the provider
    final themesValue = ref.read(slideThemesProvider);
    Map<String, dynamic>? themeObject;

    final themes = themesValue.asData?.value;
    if (themes != null && themes.isNotEmpty) {
      final selectedTheme = themes.firstWhere(
        (t) => t.id == themeId,
        orElse: () => themes.first,
      );
      themeObject = selectedTheme.toJson();
    } else {
      // Fallback only if themes are not loaded content, but ideally this should also be validated
      throw const FormatException('Themes not loaded. Please try again.');
    }

    // Save preferences
    try {
      final prefsService = ref.read(generationPreferencesServiceProvider);
      prefsService.savePresentationThemeId(themeId);
      prefsService.savePresentationImageModelId(imageModel.id);
      prefsService.savePresentationLanguage(state.language);
      if (outlineModel != null) {
        prefsService.savePresentationTextModelId(outlineModel.id);
      }
    } catch (e) {
      // Ignore errors during preference saving, as it shouldn't block generation
    }

    final presentationData = {
      'theme': themeObject,
      'viewport': SlideViewport.standard.toJson(),
    };

    final othersData = {
      'contentLength': state.avoidContent.isNotEmpty ? state.avoidContent : '',
      'imageModel': {'name': imageModel.name, 'provider': imageModel.provider},
    };

    return PresentationGenerateRequest(
      model: outlineModel?.name ?? ModelInfo.defaultTextModelName,
      provider: outlineModel?.provider ?? ModelInfo.defaultTextModelProvider,
      language: state.language,
      slideCount: state.slideCount,
      outline: state.outline,
      presentation: presentationData,
      others: othersData,
      grade: state.grade,
      subject: state.subject,
      fileUrls: state.fileUrls.isNotEmpty ? state.fileUrls : null,
    );
  }
}
