part of 'presentation_generation_controller_provider.dart';

// Form state controller for presentation generation
class PresentationGenerationFormController
    extends Notifier<PresentationGenerationRequest> {
  @override
  PresentationGenerationRequest build() {
    return PresentationGenerationRequest(
      outline: '',
      model: 'gpt-4',
      theme: 'modern',
    );
  }

  void setOutline(String outline) {
    state = state.copyWith(outline: outline);
  }

  void updateModel(String model) {
    state = state.copyWith(model: model);
  }

  void updateTheme(String theme) {
    state = state.copyWith(theme: theme);
  }

  void updateAvoid(String? avoid) {
    state = state.copyWith(avoid: avoid);
  }
}

// Generation controller for presentation
class GeneratePresentationController
    extends AsyncNotifier<PresentationGenerationResponse?> {
  @override
  Future<PresentationGenerationResponse?> build() async => null;

  Future<void> generatePresentation(
    PresentationGenerationRequest request,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(presentationGenerationServiceProvider)
          .generatePresentation(request);
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}
