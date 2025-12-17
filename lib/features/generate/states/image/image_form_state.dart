import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';

/// State class representing the image generation form inputs.
class ImageFormState {
  /// The text prompt to generate the image from
  final String prompt;

  /// Selected AI model for generation
  final AIModel? selectedModel;

  /// The aspect ratio of the generated image
  final String aspectRatio;

  /// The art style for the generated image
  final String artStyle;

  /// Additional art description
  final String artDescription;

  /// Additional theme description
  final String themeDescription;

  const ImageFormState({
    this.prompt = '',
    this.selectedModel,
    this.aspectRatio = '1:1',
    required this.artStyle,
    required this.artDescription,
    required this.themeDescription,
  });

  ImageFormState copyWith({
    String? prompt,
    AIModel? selectedModel,
    bool clearSelectedModel = false,
    String? aspectRatio,
    String? artStyle,
    String? artDescription,
    String? themeDescription,
  }) {
    return ImageFormState(
      prompt: prompt ?? this.prompt,
      selectedModel: clearSelectedModel
          ? null
          : (selectedModel ?? this.selectedModel),
      aspectRatio: aspectRatio ?? this.aspectRatio,
      artStyle: artStyle ?? this.artStyle,
      artDescription: artDescription ?? this.artDescription,
      themeDescription: themeDescription ?? this.themeDescription,
    );
  }

  /// Validate if form is ready for submission
  bool get isValid => prompt.trim().isNotEmpty && selectedModel != null;

  /// Validate prompt length
  bool get isPromptValid => prompt.trim().isNotEmpty && prompt.length <= 1000;
}
