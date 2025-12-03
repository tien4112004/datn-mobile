import 'package:datn_mobile/features/generate/controllers/states/text_model_state.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class TextModelStateNotifier extends StateNotifier<TextModelState> {
  TextModelStateNotifier(super.initialState);

  void selectModel(AIModel model) {
    state = state.copyWith(selectedModel: model);
  }

  void clearSelection() {
    state = state.copyWith(selectedModel: null);
  }
}
