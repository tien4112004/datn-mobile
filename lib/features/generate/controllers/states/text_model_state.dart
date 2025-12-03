import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';

class TextModelState {
  AIModel? selectedModel;

  TextModelState({this.selectedModel});

  TextModelState copyWith({AIModel? selectedModel}) {
    return TextModelState(selectedModel: selectedModel ?? this.selectedModel);
  }
}
