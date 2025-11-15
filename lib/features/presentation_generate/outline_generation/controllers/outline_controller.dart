part of 'outline_controller_provider.dart';

// Form state controller for outline generation
class OutlineFormController extends Notifier<OutlineRequest> {
  @override
  OutlineRequest build() {
    return OutlineRequest(
      topic: '',
      language: 'en',
      model: 'gpt-4',
      slideCount: 10,
      provider: 'openai',
    );
  }

  void updateTopic(String topic) {
    state = state.copyWith(topic: topic);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void updateModel(String model) {
    state = state.copyWith(model: model);
  }

  void updateSlideCount(int slideCount) {
    state = state.copyWith(slideCount: slideCount);
  }

  void updateProvider(String provider) {
    state = state.copyWith(provider: provider);
  }
}

// Generation controller for streaming outline
class GenerateOutlineController extends AsyncNotifier<Stream<String>?> {
  @override
  Future<Stream<String>?> build() async => null;

  Future<void> generateOutline(OutlineRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(outlineServiceProvider)
          .generateOutlineStream(request);
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}
