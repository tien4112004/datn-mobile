import 'package:datn_mobile/features/generate/states/image_model_state.dart';
import 'package:datn_mobile/features/generate/states/text_model_state.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';

class ModelsState {
  final List<AIModel> availableModels;
  final bool isLoading;
  final String? errorMessage;
  final TextModelState? textModelState;
  final ImageModelState? imageModelState;

  ModelsState({
    this.textModelState,
    this.imageModelState,
    required this.availableModels,
    this.isLoading = false,
    this.errorMessage,
  });

  ModelsState copyWith({
    List<AIModel>? availableModels,
    bool? isLoading,
    String? errorMessage,
    TextModelState? textModelState,
    ImageModelState? imageModelState,
  }) {
    return ModelsState(
      availableModels: availableModels ?? this.availableModels,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      textModelState: textModelState ?? this.textModelState,
      imageModelState: imageModelState ?? this.imageModelState,
    );
  }

  AIModel? get selectedTextModel {
    return textModelState?.selectedModel;
  }

  AIModel? get selectedImageModel {
    return imageModelState?.selectedModel;
  }
}
