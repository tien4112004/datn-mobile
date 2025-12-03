import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';

class ImageModelState {
  final AIModel? selectedModel;

  ImageModelState({this.selectedModel});

  ImageModelState copyWith({AIModel? selectedModel}) {
    return ImageModelState(selectedModel: selectedModel ?? this.selectedModel);
  }
}
