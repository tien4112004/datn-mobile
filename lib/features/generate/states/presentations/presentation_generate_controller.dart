part of '../controller_provider.dart';

/// Controller for managing presentation generation operations.
///
/// Uses request ID tracking to prevent race conditions when listeners
/// check for state changes in the UI.
class PresentationGenerateController
    extends AsyncNotifier<PresentationGenerateState> {
  @override
  Future<PresentationGenerateState> build() async {
    return PresentationGenerateState.initial();
  }

  /// Generate a unique request ID for tracking requests
  String _generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> generateOutline(OutlineGenerateRequest outlineData) async {
    final requestId = _generateRequestId();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(presentationGenerateServiceProvider)
          .generateOutline(outlineData);

      return PresentationGenerateState.outlineSuccess(response, requestId);
    });
  }

  Future<void> generatePresentation(PresentationGenerateRequest request) async {
    final requestId = _generateRequestId();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(presentationGenerateServiceProvider)
          .generatePresentation(request);

      return PresentationGenerateState.presentationSuccess(response, requestId);
    });
  }

  void reset() {
    state = AsyncData(PresentationGenerateState.initial());
  }
}
