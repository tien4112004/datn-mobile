import 'package:AIPrimary/features/generate/domain/entity/mindmap_node_content.dart';

/// State class representing the mindmap generation state.
class MindmapGenerateState {
  /// The generated mindmap content (tree structure)
  final MindmapNodeContent? generatedMindmap;

  const MindmapGenerateState({this.generatedMindmap});

  factory MindmapGenerateState.initial() => const MindmapGenerateState();

  factory MindmapGenerateState.success(MindmapNodeContent mindmap) =>
      MindmapGenerateState(generatedMindmap: mindmap);

  bool get hasMindmap => generatedMindmap != null;
  bool get isLoading => generatedMindmap == null;

  MindmapGenerateState copyWith({MindmapNodeContent? generatedMindmap}) {
    return MindmapGenerateState(
      generatedMindmap: generatedMindmap ?? this.generatedMindmap,
    );
  }
}
