import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';

class ImageModelState {
  final AIModel? selectedModel;

  ImageModelState({this.selectedModel});

  ImageModelState copyWith({AIModel? selectedModel}) {
    return ImageModelState(selectedModel: selectedModel ?? this.selectedModel);
  }
}
