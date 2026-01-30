import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';

class TextModelState {
  AIModel? selectedModel;

  TextModelState({this.selectedModel});

  TextModelState copyWith({AIModel? selectedModel}) {
    return TextModelState(selectedModel: selectedModel ?? this.selectedModel);
  }
}
