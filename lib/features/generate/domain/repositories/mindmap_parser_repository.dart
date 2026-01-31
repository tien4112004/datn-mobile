import 'package:AIPrimary/features/generate/domain/entity/mindmap_node_content.dart';

/// Repository interface for mindmap parsing operations.
///
/// This abstraction decouples the UI from the service layer implementation,
/// making the code more testable and maintainable.
abstract class MindmapParserRepository {
  /// Parse a JSON string response into a MindmapNodeContent tree structure.
  ///
  /// Expected JSON format (as returned from API):
  /// ```json
  /// {
  ///   "content": "Root topic",
  ///   "children": [
  ///     {
  ///       "content": "Branch 1",
  ///       "children": [
  ///         { "content": "Leaf 1" },
  ///         { "content": "Leaf 2" }
  ///       ]
  ///     },
  ///     {
  ///       "content": "Branch 2"
  ///     }
  ///   ]
  /// }
  /// ```
  MindmapNodeContent parseJsonToMindmap(String jsonString);

  /// Convert a MindmapNodeContent tree structure back to JSON string.
  String mindmapToJson(MindmapNodeContent mindmap);

  /// Extract all leaf nodes (nodes without children) from a mindmap.
  ///
  /// This is useful for analyzing the structure and extracting all concepts.
  List<String> extractLeafNodes(MindmapNodeContent mindmap);

  /// Count the total number of nodes in the mindmap tree.
  int countTotalNodes(MindmapNodeContent mindmap);

  /// Get the maximum depth of the mindmap tree.
  int getMaxDepth(MindmapNodeContent mindmap);
}
