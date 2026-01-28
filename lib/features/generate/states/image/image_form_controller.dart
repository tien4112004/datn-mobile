part of '../controller_provider.dart';

/// Controller for managing the image form state.
class ImageFormController extends Notifier<ImageFormState> {
  @override
  ImageFormState build() {
    // Load persisted image model
    final prefs = ref.read(generationPreferencesServiceProvider);
    final savedModelId = prefs.getImageGenerateModelId();
    if (savedModelId != null) {
      ref.listen(modelsControllerPod(ModelType.image), (_, next) {
        next.whenData((state) {
          final model = state.availableModels
              .where((m) => m.id == savedModelId)
              .firstOrNull;
          if (model != null) {
            updateModel(model);
          }
        });
      });
    }

    // Initialize with empty art style; UI will set it to first available from API
    return const ImageFormState(
      artDescription: '',
      themeDescription: '',
      artStyle: '',
    );
  }

  void updatePrompt(String prompt) {
    state = state.copyWith(prompt: prompt);
  }

  void updateModel(AIModel model) {
    state = state.copyWith(selectedModel: model);
    ref
        .read(generationPreferencesServiceProvider)
        .saveImageGenerateModelId(model.id);
  }

  void updateAspectRatio(String aspectRatio) {
    state = state.copyWith(aspectRatio: aspectRatio);
  }

  void updateArtStyle(String? artStyle) {
    state = state.copyWith(artStyle: artStyle);
  }

  void updateArtDescription(String? artDescription) {
    state = state.copyWith(artDescription: artDescription);
  }

  void updateThemeDescription(String? themeDescription) {
    state = state.copyWith(themeDescription: themeDescription);
  }

  void reset() {
    // Preserve preference-related fields, only clear user-input fields
    state = ImageFormState(
      selectedModel: state.selectedModel,
      // User-input fields are cleared
      artDescription: '',
      themeDescription: '',
      artStyle: '',
    );
  }
}
