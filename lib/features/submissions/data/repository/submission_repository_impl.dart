import 'package:AIPrimary/features/assignments/data/dto/api/assignment_response.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/submissions/data/dto/answer_data_dto.dart';
import 'package:AIPrimary/features/submissions/data/dto/statistics_dto.dart';
import 'package:AIPrimary/features/submissions/data/dto/submission_dto.dart';
import 'package:AIPrimary/features/submissions/data/source/submission_remote_source.dart';
import 'package:AIPrimary/features/submissions/domain/entity/answer_entity.dart';
import 'package:AIPrimary/features/submissions/domain/entity/statistics_entity.dart';
import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';
import 'package:AIPrimary/features/submissions/domain/repository/submission_repository.dart';

/// Implementation of SubmissionRepository using remote API source
class SubmissionRepositoryImpl implements SubmissionRepository {
  final SubmissionRemoteSource _remoteSource;

  SubmissionRepositoryImpl(this._remoteSource);

  @override
  Future<SubmissionEntity> createSubmission({
    required String postId,
    required String studentId,
    required List<AnswerEntity> answers,
  }) async {
    try {
      final request = answers.toCreateRequest(studentId, postId);
      final response = await _remoteSource.createSubmission(postId, request);

      if (response.data == null) {
        throw Exception('Failed to create submission: No data returned');
      }

      return response.data!.toEntity();
    } catch (e) {
      throw Exception('Failed to create submission: $e');
    }
  }

  @override
  Future<List<SubmissionEntity>> getStudentSubmissions({
    required String assignmentId,
    required String studentId,
  }) async {
    try {
      final response = await _remoteSource.getStudentSubmissions(
        assignmentId,
        studentId,
      );

      return response.data?.map((dto) => dto.toEntity()).toList() ?? [];
    } catch (e) {
      throw Exception('Failed to get student submissions: $e');
    }
  }

  @override
  Future<ValidationResult> validateAttempt({
    required String assignmentId,
    required String studentId,
    required List<AnswerEntity> answers,
  }) async {
    try {
      final request = ValidateSubmissionRequestDto(
        studentId: studentId,
        answers: answers.map((answer) => answer.toDto()).toList(),
      );

      final response = await _remoteSource.validateAttempt(
        assignmentId,
        request,
      );

      if (response.data == null) {
        throw Exception('Failed to validate attempt: No data returned');
      }

      return response.data!.toEntity();
    } catch (e) {
      throw Exception('Failed to validate attempt: $e');
    }
  }

  @override
  Future<AssignmentEntity> getAssignmentByPostId(String postId) async {
    try {
      final response = await _remoteSource.getAssignmentPostById(postId);

      if (response.data == null) {
        throw Exception('Assignment not found');
      }

      return response.data!.toEntity();
    } catch (e) {
      throw Exception('Failed to get assignment: $e');
    }
  }

  @override
  Future<List<SubmissionEntity>> getPostSubmissions(String postId) async {
    try {
      final response = await _remoteSource.getPostSubmissions(postId);

      return response.data?.map((dto) => dto.toEntity()).toList() ?? [];
    } catch (e) {
      throw Exception('Failed to get post submissions: $e');
    }
  }

  @override
  Future<SubmissionEntity> getSubmissionById(String submissionId) async {
    try {
      final response = await _remoteSource.getSubmissionById(submissionId);

      if (response.data == null) {
        throw Exception('Submission not found');
      }

      return response.data!.toEntity();
    } catch (e) {
      throw Exception('Failed to get submission: $e');
    }
  }

  @override
  Future<SubmissionEntity> gradeSubmission({
    required String submissionId,
    required Map<String, double> questionScores,
    Map<String, String>? questionFeedback,
    String? overallFeedback,
  }) async {
    try {
      final request = GradeSubmissionRequestDto(
        questionScores: questionScores,
        questionFeedback: questionFeedback,
        overallFeedback: overallFeedback,
      );

      final response = await _remoteSource.gradeSubmission(
        submissionId,
        request,
      );

      if (response.data == null) {
        throw Exception('Failed to grade submission: No data returned');
      }

      return response.data!.toEntity();
    } catch (e) {
      throw Exception('Failed to grade submission: $e');
    }
  }

  @override
  Future<SubmissionStatisticsEntity> getSubmissionStatistics(
    String postId,
  ) async {
    try {
      final response = await _remoteSource.getSubmissionStatistics(postId);

      if (response.data == null) {
        throw Exception('Failed to get statistics: No data returned');
      }

      return response.data!.toEntity();
    } catch (e) {
      throw Exception('Failed to get submission statistics: $e');
    }
  }
}
