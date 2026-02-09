/// Grade entity for a single question in a submission
class GradeEntity {
  final double score;
  final double maxScore;
  final String? feedback;
  final bool isAutoGraded;

  const GradeEntity({
    required this.score,
    required this.maxScore,
    this.feedback,
    required this.isAutoGraded,
  });

  /// Calculate percentage score (0-100)
  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;

  /// Check if got perfect score
  bool get isPerfect => score >= maxScore && maxScore > 0;

  /// Check if passing (>= 70%)
  bool get isPassing => percentage >= 70;

  GradeEntity copyWith({
    double? score,
    double? maxScore,
    String? feedback,
    bool? isAutoGraded,
  }) {
    return GradeEntity(
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      feedback: feedback ?? this.feedback,
      isAutoGraded: isAutoGraded ?? this.isAutoGraded,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeEntity &&
          runtimeType == other.runtimeType &&
          score == other.score &&
          maxScore == other.maxScore &&
          feedback == other.feedback &&
          isAutoGraded == other.isAutoGraded;

  @override
  int get hashCode => Object.hash(score, maxScore, feedback, isAutoGraded);

  @override
  String toString() =>
      'GradeEntity(score: $score/$maxScore, isAutoGraded: $isAutoGraded)';
}
