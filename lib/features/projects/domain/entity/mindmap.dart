class Mindmap {
  final String id;
  final String title;
  final String? description;
  final List<MindmapNode> nodes;
  final List<MindmapEdge> edges;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Mindmap({
    required this.id,
    required this.title,
    this.description,
    required this.nodes,
    required this.edges,
    this.createdAt,
    this.updatedAt,
  });

  String? get thumbnail => null;

  Mindmap copyWith({
    String? id,
    String? title,
    String? description,
    List<MindmapNode>? nodes,
    List<MindmapEdge>? edges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Mindmap(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MindmapNode {
  final String id;
  final String type;
  final Map<String, dynamic> extraFields;

  MindmapNode({
    required this.id,
    required this.type,
    required this.extraFields,
  });

  MindmapNode copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? extraFields,
  }) {
    return MindmapNode(
      id: id ?? this.id,
      type: type ?? this.type,
      extraFields: extraFields ?? this.extraFields,
    );
  }
}

class MindmapEdge {
  final String id;
  final String type;
  final Map<String, dynamic>? extraFields;

  MindmapEdge({required this.id, required this.type, this.extraFields});

  MindmapEdge copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? extraFields,
  }) {
    return MindmapEdge(
      id: id ?? this.id,
      type: type ?? this.type,
      extraFields: extraFields ?? this.extraFields,
    );
  }
}
