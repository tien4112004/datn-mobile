part of '../controller_provider.dart';

/// Controller for managing the presentation form state.
///
/// State is explicitly kept alive to prevent loss during navigation
/// between the generation, customization, and editor pages.
class PresentationFormController extends Notifier<PresentationFormState> {
  @override
  PresentationFormState build() {
    return const PresentationFormState();
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
  }

  void updateOutlineModel(AIModel model) {
    state = state.copyWith(outlineModel: model);
  }

  // Step 2 updates
  void updateTheme(PresentationTheme theme) {
    state = state.copyWith(theme: theme);
  }

  void updateThemeId(String themeId) {
    state = state.copyWith(themeId: themeId);
  }

  void updateImageModel(AIModel model) {
    state = state.copyWith(imageModel: model);
  }

  void updateAvoidContent(String content) {
    state = state.copyWith(avoidContent: content);
  }

  // Outline management
  void setOutline(String outline) {
    state = state.copyWith(outline: outline, currentStep: 2);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void reset() {
    state = const PresentationFormState();
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
    );
  }

  // Create presentation request for Step 2
  PresentationGenerateRequest toPresentationRequest(WidgetRef ref) {
    final outlineModel = state.outlineModel;
    final imageModel = state.imageModel;

    // Get the full theme object from the provider
    final themesAsync = ref.read(slideThemesProvider);
    Map<String, dynamic>? themeObject;

    themesAsync.whenData((themes) {
      if (state.themeId != null) {
        final selectedTheme = themes.firstWhere(
          (t) => t.id == state.themeId,
          orElse: () => themes.first,
        );
        themeObject = selectedTheme.toJson();
      } else {
        themeObject = themes.first.toJson();
      }
    });

    final presentationData = {
      'theme': themeObject ?? {'id': state.themeId ?? 'modern'},
      'viewport': SlideViewport.standard.toJson(),
    };

    final othersData = {
      'contentLength': state.avoidContent.isNotEmpty ? state.avoidContent : '',
      'imageModel': imageModel != null
          ? {'name': imageModel.name, 'provider': imageModel.provider}
          : {
              'name': 'google/gemini-2.5-flash-image-preview',
              'provider': 'openRouter',
            },
    };

    return PresentationGenerateRequest(
      model: outlineModel?.name ?? 'gpt-4o',
      provider: outlineModel?.provider ?? 'openai',
      language: state.language,
      slideCount: state.slideCount,
      outline: state.outline,
      presentation: presentationData,
      others: othersData,
    );
  }
}
