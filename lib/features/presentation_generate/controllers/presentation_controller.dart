part of 'controller_provider.dart';

// Form state controller
class PresentationFormController extends Notifier<PresentationRequest> {
  @override
  PresentationRequest build() {
    return PresentationRequest(
      model: PresentationModel.fast,
      grade: PresentationGrade.grade1,
      theme: PresentationTheme.lorems,
      description: '',
    );
  }

  void updateModel(PresentationModel model) {
    state = state.copyWith(model: model);
  }

  void updateGrade(PresentationGrade grade) {
    state = state.copyWith(grade: grade);
  }

  void updateTheme(PresentationTheme theme) {
    state = state.copyWith(theme: theme);
  }

  void updateSlides(int? slides) {
    state = state.copyWith(slides: slides);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateAvoid(String? avoid) {
    state = state.copyWith(avoid: avoid);
  }

  void updateAttachments(List<String>? attachments) {
    state = state.copyWith(attachments: attachments);
  }
}

// Generation controller
class GeneratePresentationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> generatePresentation(PresentationRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(presentationServiceProvider).generatePresentation(request);
      // Here you might want to navigate to a result page or show success
    });
  }
}