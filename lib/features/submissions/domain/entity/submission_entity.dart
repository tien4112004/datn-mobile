import 'package:AIPrimary/features/submissions/domain/entity/answer_entity.dart';

/// Submission status enum
enum SubmissionStatus {
  submitted,
  graded,
  inProgress;

  String get value {
    switch (this) {
      case SubmissionStatus.submitted:
        return 'submitted';
      case SubmissionStatus.graded:
        return 'graded';
      case SubmissionStatus.inProgress:
        return 'in_progress';
    }
  }

  static SubmissionStatus fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'submitted':
      case 'pending': // Backend uses "pending" for submitted status
        return SubmissionStatus.submitted;
      case 'graded':
        return SubmissionStatus.graded;
      case 'in_progress':
      case 'inprogress':
        return SubmissionStatus.inProgress;
      default:
        return SubmissionStatus.submitted;
    }
  }
}

/// Submission entity representing a student's assignment attempt
class SubmissionEntity {
  final String id;
  final String assignmentId;
  final String postId;
  final String studentId;
  final StudentEntity student;
  final List<AnswerEntity> questions;
  final SubmissionStatus status;
  final double? score;
  final double maxScore;
  final String? overallFeedback;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  const SubmissionEntity({
    required this.id,
    required this.assignmentId,
    required this.postId,
    required this.studentId,
    required this.student,
    required this.questions,
    required this.status,
    this.score,
    required this.maxScore,
    this.overallFeedback,
    required this.submittedAt,
    this.gradedAt,
  });

  /// Calculate score percentage (0-100)
  double get scorePercentage {
    if (score == null || maxScore == 0) return 0;
    return (score! / maxScore) * 100;
  }

  /// Check if submission has been graded
  bool get isGraded => status == SubmissionStatus.graded;

  /// Check if submission is pending grading
  bool get isPending => status == SubmissionStatus.submitted && !isGraded;

  /// Count of answered questions
  int get answeredCount => questions.where((a) => a.isAnswered).length;

  /// Total question count
  int get totalQuestions => questions.length;

  /// Check if all questions are answered
  bool get isComplete => answeredCount == totalQuestions;

  SubmissionEntity copyWith({
    String? id,
    String? assignmentId,
    String? postId,
    String? studentId,
    StudentEntity? student,
    List<AnswerEntity>? answers,
    SubmissionStatus? status,
    double? totalScore,
    double? maxScore,
    String? overallFeedback,
    DateTime? submittedAt,
    DateTime? gradedAt,
  }) {
    return SubmissionEntity(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      postId: postId ?? this.postId,
      studentId: studentId ?? this.studentId,
      student: student ?? this.student,
      questions: answers ?? questions,
      status: status ?? this.status,
      score: totalScore ?? score,
      maxScore: maxScore ?? this.maxScore,
      overallFeedback: overallFeedback ?? this.overallFeedback,
      submittedAt: submittedAt ?? this.submittedAt,
      gradedAt: gradedAt ?? this.gradedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SubmissionEntity(id: $id, student: $student, status: $status, score: $score/$maxScore)';
}

class StudentEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  const StudentEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });
}
