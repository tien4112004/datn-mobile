part of '../controller_provider.dart';

/// Controller for managing mindmap generation operations.
class MindmapGenerateController extends AsyncNotifier<MindmapGenerateState> {
  @override
  Future<MindmapGenerateState> build() async {
    return MindmapGenerateState.initial();
  }

  /// Generate a unique request ID for tracking requests
  String _generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Generate a mindmap based on the current form state
  Future<void> generateMindmap() async {
    final formState = ref.read(mindmapFormControllerProvider);

    if (!formState.isValid) {
      throw ArgumentError('Form is not valid');
    }

    final requestId = _generateRequestId();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(mindmapServiceProvider)
          .generateMindmap(
            topic: formState.topic,
            model: formState.selectedModel!,
            language: formState.language,
            maxDepth: formState.maxDepth,
            maxBranchesPerNode: formState.maxBranchesPerNode,
          );

      return MindmapGenerateState.success(response, requestId);
    });
  }

  void reset() {
    state = AsyncData(MindmapGenerateState.initial());
  }
}
