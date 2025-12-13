import 'package:datn_mobile/features/generate/data/dto/mindmap_node_content_dto.dart';

/// Domain entity representing a node in the generated mindmap.
/// This is a recursive tree structure where each node can have children.
class MindmapNodeContent {
  /// Text content of the node
  final String content;

  /// Child nodes branching from this node
  final List<MindmapNodeContent> children;

  const MindmapNodeContent({required this.content, this.children = const []});

  /// Convert from DTO
  factory MindmapNodeContent.fromDto(MindmapNodeContentDto dto) {
    return MindmapNodeContent(
      content: dto.content,
      children:
          dto.children
              ?.map((child) => MindmapNodeContent.fromDto(child))
              .toList() ??
          [],
    );
  }

  /// Convert to DTO
  MindmapNodeContentDto toDto() {
    return MindmapNodeContentDto(
      content: content,
      children: children.isEmpty
          ? null
          : children.map((c) => c.toDto()).toList(),
    );
  }

  MindmapNodeContent copyWith({
    String? content,
    List<MindmapNodeContent>? children,
  }) {
    return MindmapNodeContent(
      content: content ?? this.content,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MindmapNodeContent &&
        other.content == content &&
        _listEquals(other.children, children);
  }

  @override
  int get hashCode => Object.hash(content, children);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
