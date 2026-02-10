import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Score distribution bucket for visualization
class ScoreDistributionBucket {
  final String range; // "below-70", "70-79", "80-89", "90-100"
  final int count;

  const ScoreDistributionBucket({required this.range, required this.count});

  /// Get user-friendly label for the range
  String getLabel(Translations t) {
    switch (range) {
      case 'below-70':
        return t.submissions.statistics.below70;
      case '70-79':
        return '70-79%';
      case '80-89':
        return '80-89%';
      case '90-100':
        return '90-100%';
      default:
        return range;
    }
  }

  /// Get color coding for the range based on performance
  Color get color {
    switch (range) {
      case '90-100':
        return Colors.green;
      case '80-89':
        return Colors.green.shade300;
      case '70-79':
        return Colors.orange;
      case 'below-70':
      default:
        return Colors.red;
    }
  }

  /// Get minimum percentage for the range
  double get minPercentage {
    switch (range) {
      case 'below-70':
        return 0;
      case '70-79':
        return 70;
      case '80-89':
        return 80;
      case '90-100':
        return 90;
      default:
        return 0;
    }
  }

  /// Get maximum percentage for the range
  double get maxPercentage {
    switch (range) {
      case 'below-70':
        return 70;
      case '70-79':
        return 79;
      case '80-89':
        return 89;
      case '90-100':
        return 100;
      default:
        return 100;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreDistributionBucket &&
          runtimeType == other.runtimeType &&
          range == other.range &&
          count == other.count;

  @override
  int get hashCode => range.hashCode ^ count.hashCode;
}

/// Main statistics entity with computed properties
class SubmissionStatisticsEntity {
  final int totalSubmissions;
  final int gradedCount;
  final int pendingCount;
  final int inProgressCount;
  final double? averageScore;
  final double? highestScore;
  final double? lowestScore;
  final Map<String, int> scoreDistribution;

  const SubmissionStatisticsEntity({
    required this.totalSubmissions,
    required this.gradedCount,
    required this.pendingCount,
    required this.inProgressCount,
    this.averageScore,
    this.highestScore,
    this.lowestScore,
    required this.scoreDistribution,
  });

  /// Convert score distribution map to list of buckets for UI
  List<ScoreDistributionBucket> get distributionBuckets {
    return scoreDistribution.entries
        .map((e) => ScoreDistributionBucket(range: e.key, count: e.value))
        .toList();
  }

  /// Calculate percentage of graded submissions
  double get gradedPercentage {
    if (totalSubmissions == 0) return 0.0;
    return (gradedCount / totalSubmissions) * 100;
  }

  /// Get maximum count value in distribution for chart scaling
  int get maxBucketCount {
    if (scoreDistribution.isEmpty) return 0;
    return scoreDistribution.values.reduce((a, b) => a > b ? a : b);
  }

  /// Check if there are any scores available
  bool get hasScores => averageScore != null;

  /// Check if all submissions are graded
  bool get isFullyGraded =>
      totalSubmissions > 0 && gradedCount == totalSubmissions;

  /// Check if there are any submissions
  bool get hasSubmissions => totalSubmissions > 0;

  /// Get completion percentage (graded + in-progress / total)
  double get completionPercentage {
    if (totalSubmissions == 0) return 0.0;
    return ((gradedCount + inProgressCount) / totalSubmissions) * 100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionStatisticsEntity &&
          runtimeType == other.runtimeType &&
          totalSubmissions == other.totalSubmissions &&
          gradedCount == other.gradedCount &&
          pendingCount == other.pendingCount &&
          inProgressCount == other.inProgressCount &&
          averageScore == other.averageScore &&
          highestScore == other.highestScore &&
          lowestScore == other.lowestScore;

  @override
  int get hashCode =>
      totalSubmissions.hashCode ^
      gradedCount.hashCode ^
      pendingCount.hashCode ^
      inProgressCount.hashCode ^
      averageScore.hashCode ^
      highestScore.hashCode ^
      lowestScore.hashCode;

  SubmissionStatisticsEntity copyWith({
    int? totalSubmissions,
    int? gradedCount,
    int? pendingCount,
    int? inProgressCount,
    double? averageScore,
    double? highestScore,
    double? lowestScore,
    Map<String, int>? scoreDistribution,
  }) {
    return SubmissionStatisticsEntity(
      totalSubmissions: totalSubmissions ?? this.totalSubmissions,
      gradedCount: gradedCount ?? this.gradedCount,
      pendingCount: pendingCount ?? this.pendingCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      averageScore: averageScore ?? this.averageScore,
      highestScore: highestScore ?? this.highestScore,
      lowestScore: lowestScore ?? this.lowestScore,
      scoreDistribution: scoreDistribution ?? this.scoreDistribution,
    );
  }
}
