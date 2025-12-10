import 'dart:convert';

import 'package:datn_mobile/features/generate/domain/entity/mindmap_node_content.dart';
import 'package:flutter/foundation.dart';

/// Utility class for parsing JSON mindmap responses to tree structures and vice versa.
class MindmapParser {
  /// Parse JSON string response from API into MindmapNodeContent tree structure.
  ///
  /// The JSON should follow the structure:
  /// ```json
  /// {
  ///   "content": "Root topic",
  ///   "children": [...]
  /// }
  /// ```
  static MindmapNodeContent parseJsonToMindmap(String jsonString) {
    try {
      debugPrint('Parsing mindmap JSON: $jsonString');

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return _parseNodeFromJson(json);
    } catch (e) {
      debugPrint('Error parsing mindmap JSON: $e');
      throw FormatException('Failed to parse mindmap JSON: $e');
    }
  }

  /// Parse a single node from JSON recursively.
  static MindmapNodeContent _parseNodeFromJson(Map<String, dynamic> json) {
    final content = json['content'] as String?;
    if (content == null || content.isEmpty) {
      throw const FormatException('Node content cannot be empty');
    }

    final childrenJson = json['children'] as List<dynamic>?;
    final children = <MindmapNodeContent>[];

    if (childrenJson != null && childrenJson.isNotEmpty) {
      for (final childJson in childrenJson) {
        if (childJson is Map<String, dynamic>) {
          children.add(_parseNodeFromJson(childJson));
        }
      }
    }

    return MindmapNodeContent(content: content, children: children);
  }

  /// Convert MindmapNodeContent tree structure back to JSON string.
  static String mindmapToJson(MindmapNodeContent mindmap) {
    try {
      final json = _nodeToJson(mindmap);
      return jsonEncode(json);
    } catch (e) {
      debugPrint('Error converting mindmap to JSON: $e');
      throw FormatException('Failed to convert mindmap to JSON: $e');
    }
  }

  /// Convert a single node to JSON recursively.
  static Map<String, dynamic> _nodeToJson(MindmapNodeContent node) {
    return {
      'content': node.content,
      if (node.children.isNotEmpty)
        'children': node.children.map(_nodeToJson).toList(),
    };
  }

  /// Extract all leaf nodes (nodes without children) from the mindmap.
  static List<String> extractLeafNodes(MindmapNodeContent mindmap) {
    final leaves = <String>[];
    _extractLeaves(mindmap, leaves);
    return leaves;
  }

  /// Recursively extract all leaf nodes.
  static void _extractLeaves(MindmapNodeContent node, List<String> leaves) {
    if (node.children.isEmpty) {
      leaves.add(node.content);
    } else {
      for (final child in node.children) {
        _extractLeaves(child, leaves);
      }
    }
  }

  /// Count the total number of nodes in the mindmap tree.
  static int countTotalNodes(MindmapNodeContent mindmap) {
    int count = 1; // Count the root node
    for (final child in mindmap.children) {
      count += _countNodesRecursive(child);
    }
    return count;
  }

  /// Recursively count nodes in the tree.
  static int _countNodesRecursive(MindmapNodeContent node) {
    int count = 1; // Count this node
    for (final child in node.children) {
      count += _countNodesRecursive(child);
    }
    return count;
  }

  /// Get the maximum depth of the mindmap tree.
  static int getMaxDepth(MindmapNodeContent mindmap) {
    return _calculateDepth(mindmap);
  }

  /// Recursively calculate the depth of the tree.
  static int _calculateDepth(MindmapNodeContent node) {
    if (node.children.isEmpty) {
      return 1;
    }

    int maxChildDepth = 0;
    for (final child in node.children) {
      final childDepth = _calculateDepth(child);
      maxChildDepth = childDepth > maxChildDepth ? childDepth : maxChildDepth;
    }

    return 1 + maxChildDepth;
  }

  /// Get all nodes at a specific depth level.
  static List<String> getNodesAtDepth(MindmapNodeContent mindmap, int depth) {
    final nodesAtDepth = <String>[];
    _getNodesAtDepthRecursive(mindmap, depth, 1, nodesAtDepth);
    return nodesAtDepth;
  }

  /// Recursively get nodes at a specific depth.
  static void _getNodesAtDepthRecursive(
    MindmapNodeContent node,
    int targetDepth,
    int currentDepth,
    List<String> result,
  ) {
    if (currentDepth == targetDepth) {
      result.add(node.content);
      return;
    }

    if (currentDepth < targetDepth) {
      for (final child in node.children) {
        _getNodesAtDepthRecursive(child, targetDepth, currentDepth + 1, result);
      }
    }
  }
}
