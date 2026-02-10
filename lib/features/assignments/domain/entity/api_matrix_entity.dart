/// Subtopic within a topic group.
/// Matches web's `{ id: string; name: string }` in MatrixDimensionTopic.subtopics.
class MatrixSubtopic {
  final String id;
  final String name;

  const MatrixSubtopic({required this.id, required this.name});
}

/// Topic group containing subtopics.
/// Matches web's `MatrixDimensionTopic` from `@aiprimary/core`.
class MatrixDimensionTopic {
  final String name;
  final List<MatrixSubtopic> subtopics;

  const MatrixDimensionTopic({required this.name, required this.subtopics});
}

/// Matrix dimension axes.
/// Defines the indices for the 3D matrix array.
class MatrixDimensions {
  final List<MatrixDimensionTopic> topics;
  final List<String> difficulties;
  final List<String> questionTypes;

  const MatrixDimensions({
    required this.topics,
    required this.difficulties,
    required this.questionTypes,
  });

  /// Flattened subtopics across all topic groups, preserving order.
  /// Each row in the 3D matrix corresponds to one flattened subtopic.
  List<MatrixSubtopic> get flatSubtopics =>
      topics.expand((t) => t.subtopics).toList();
}

/// Full API matrix — matches the JSONB `matrix` column on Assignment.
///
/// 3D structure: matrix[subtopicIndex][difficultyIndex][questionTypeIndex] = "count:points"
class ApiMatrixEntity {
  final String? grade;
  final String? subject;
  final MatrixDimensions dimensions;
  final List<List<List<String>>> matrix;
  final int totalQuestions;
  final int totalPoints;

  const ApiMatrixEntity({
    this.grade,
    this.subject,
    required this.dimensions,
    required this.matrix,
    required this.totalQuestions,
    required this.totalPoints,
  });

  /// Deep copy the 3D matrix list for safe mutation.
  List<List<List<String>>> deepCopyMatrix() {
    return matrix
        .map(
          (subtopic) => subtopic
              .map((difficulty) => List<String>.from(difficulty))
              .toList(),
        )
        .toList();
  }

  ApiMatrixEntity copyWith({
    String? grade,
    String? subject,
    MatrixDimensions? dimensions,
    List<List<List<String>>>? matrix,
    int? totalQuestions,
    int? totalPoints,
  }) {
    return ApiMatrixEntity(
      grade: grade ?? this.grade,
      subject: subject ?? this.subject,
      dimensions: dimensions ?? this.dimensions,
      matrix: matrix ?? this.matrix,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
