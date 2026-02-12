/// Topic in matrix dimensions.
/// Matches web's `MatrixDimensionTopic` from `@aiprimary/core`.
/// Subtopics are now informational only (not used for filtering/indexing).
class MatrixDimensionTopic {
  final String id;
  final String name;
  final List<String>? subtopics; // Informational subtopic names

  const MatrixDimensionTopic({
    required this.id,
    required this.name,
    this.subtopics,
  });
}

/// Matrix dimension axes.
/// Defines the indices for the 3D matrix array.
/// Matrix is now indexed as: matrix[topicIndex][difficultyIndex][questionTypeIndex]
/// (previously was indexed by subtopic, now by topic)
class MatrixDimensions {
  final List<MatrixDimensionTopic> topics;
  final List<String> difficulties;
  final List<String> questionTypes;

  const MatrixDimensions({
    required this.topics,
    required this.difficulties,
    required this.questionTypes,
  });
}

/// Full API matrix — matches the JSONB `matrix` column on Assignment.
///
/// 3D structure: matrix[topicIndex][difficultyIndex][questionTypeIndex] = "count:points"
/// Topics are the first dimension (previously was subtopic index).
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
          (topic) =>
              topic.map((difficulty) => List<String>.from(difficulty)).toList(),
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
