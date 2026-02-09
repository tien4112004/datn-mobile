import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/submissions/data/dto/submission_dto.dart';
import 'package:AIPrimary/features/submissions/domain/entity/answer_entity.dart';
import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';

/// Repository interface for submission data operations
abstract class SubmissionRepository {
  /// Create a new submission for a post's assignment
  /// Returns the created submission with auto-graded results (if applicable)
  Future<SubmissionEntity> createSubmission({
    required String postId,
    required String studentId,
    required List<AnswerEntity> answers,
  });

  /// Get student's own submissions for an assignment
  Future<List<SubmissionEntity>> getStudentSubmissions({
    required String assignmentId,
    required String studentId,
  });

  /// Validate if student can submit assignment (check attempt limits, due date, etc.)
  Future<ValidationResult> validateAttempt({
    required String assignmentId,
    required String studentId,
    required List<AnswerEntity> answers,
  });

  /// Get assignment public details (bypasses permission checks for students taking assignment)
  Future<AssignmentEntity> getAssignmentPublic(String assignmentId);

  /// Get all submissions for a specific post (teacher view)
  Future<List<SubmissionEntity>> getPostSubmissions(String postId);

  /// Get a single submission by ID
  Future<SubmissionEntity> getSubmissionById(String submissionId);

  /// Grade a submission (manual grading for open-ended questions or override auto-grades)
  Future<SubmissionEntity> gradeSubmission({
    required String submissionId,
    required Map<String, double> questionScores,
    Map<String, String>? questionFeedback,
    String? overallFeedback,
  });
}
