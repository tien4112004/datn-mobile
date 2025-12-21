part of '../controller_provider.dart';

/// Controller for managing the image form state.
class ImageFormController extends Notifier<ImageFormState> {
  @override
  ImageFormState build() {
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
    // Reset with empty art style; UI will set it to first available from API
    state = const ImageFormState(
      artDescription: '',
      themeDescription: '',
      artStyle: '',
    );
  }
}
