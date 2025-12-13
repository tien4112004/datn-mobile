part of '../controller_provider.dart';

/// Controller for managing image generation operations.
class ImageGenerateController extends AsyncNotifier<ImageGenerateState> {
  @override
  Future<ImageGenerateState> build() async {
    return ImageGenerateState.initial();
  }

  /// Generate an image based on the current form state
  Future<void> generateImage() async {
    final formState = ref.read(imageFormControllerProvider);

    if (!formState.isValid) {
      throw ArgumentError('Form is not valid');
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(imageServiceProvider)
          .generateImage(
            prompt: formState.prompt,
            model: formState.selectedModel!,
            aspectRatio: formState.aspectRatio,
            artStyle: formState.artStyle,
            artDescription: formState.artDescription,
            themeStyle: formState.themeStyle,
            themeDescription: formState.themeDescription,
          );

      return ImageGenerateState.success(response);
    });
  }

  void reset() {
    state = AsyncData(ImageGenerateState.initial());
  }
}
