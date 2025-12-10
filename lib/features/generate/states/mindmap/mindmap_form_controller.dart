part of '../controller_provider.dart';

/// Controller for managing the mindmap form state.
class MindmapFormController extends Notifier<MindmapFormState> {
  @override
  MindmapFormState build() {
    return const MindmapFormState();
  }

  void updateTopic(String topic) {
    state = state.copyWith(topic: topic);
  }

  void updateModel(AIModel model) {
    state = state.copyWith(selectedModel: model);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void updateMaxDepth(int maxDepth) {
    state = state.copyWith(maxDepth: maxDepth);
  }

  void updateMaxBranchesPerNode(int maxBranchesPerNode) {
    state = state.copyWith(maxBranchesPerNode: maxBranchesPerNode);
  }

  void reset() {
    state = const MindmapFormState();
  }
}
