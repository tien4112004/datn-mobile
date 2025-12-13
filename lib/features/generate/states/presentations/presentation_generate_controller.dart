part of '../controller_provider.dart';

/// Controller for managing presentation generation operations.
class PresentationGenerateController
    extends AsyncNotifier<PresentationGenerateState> {
  @override
  Future<PresentationGenerateState> build() async {
    return PresentationGenerateState.initial();
  }

  Future<void> generateOutline(OutlineGenerateRequest outlineData) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(presentationGenerateServiceProvider)
          .generateOutline(outlineData);

      return PresentationGenerateState.outlineSuccess(response);
    });
  }

  Future<void> generatePresentation(PresentationGenerateRequest request) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(presentationGenerateServiceProvider)
          .generatePresentation(request);

      return PresentationGenerateState.presentationSuccess(response);
    });
  }

  void reset() {
    state = AsyncData(PresentationGenerateState.initial());
  }
}
