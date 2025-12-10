import 'package:datn_mobile/features/generate/domain/entity/mindmap_node_content.dart';

/// State class representing the mindmap generation state.
class MindmapGenerateState {
  /// The generated mindmap content (tree structure)
  final MindmapNodeContent? generatedMindmap;

  /// Current request ID (used to track completion)
  final String? currentRequestId;

  /// Last processed request ID (used to detect new completions)
  final String? lastProcessedRequestId;

  const MindmapGenerateState({
    this.generatedMindmap,
    this.currentRequestId,
    this.lastProcessedRequestId,
  });

  factory MindmapGenerateState.initial() => const MindmapGenerateState();

  factory MindmapGenerateState.success(
    MindmapNodeContent mindmap,
    String requestId,
  ) => MindmapGenerateState(
    generatedMindmap: mindmap,
    lastProcessedRequestId: requestId,
  );

  bool get hasMindmap => generatedMindmap != null;

  MindmapGenerateState copyWith({
    MindmapNodeContent? generatedMindmap,
    String? currentRequestId,
    String? lastProcessedRequestId,
  }) {
    return MindmapGenerateState(
      generatedMindmap: generatedMindmap ?? this.generatedMindmap,
      currentRequestId: currentRequestId ?? this.currentRequestId,
      lastProcessedRequestId:
          lastProcessedRequestId ?? this.lastProcessedRequestId,
    );
  }
}
