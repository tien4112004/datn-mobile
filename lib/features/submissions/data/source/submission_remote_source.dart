import 'package:AIPrimary/features/submissions/data/dto/submission_dto.dart';
import 'package:AIPrimary/features/submissions/data/dto/statistics_dto.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_response.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'submission_remote_source.g.dart';

/// Retrofit API service for Submission endpoints.
/// Base URL already contains `/api`, so we only need relative paths.
@RestApi()
abstract class SubmissionRemoteSource {
  factory SubmissionRemoteSource(Dio dio, {String baseUrl}) =
      _SubmissionRemoteSource;

  // ============ Student Endpoints ============

  /// Create a new submission for a post's assignment
  /// POST /posts/{postId}/submissions
  @POST('/posts/{postId}/submissions')
  Future<ServerResponseDto<SubmissionResponseDto>> createSubmission(
    @Path('postId') String postId,
    @Body() CreateSubmissionRequestDto request,
  );

  /// Get assignment by post id
  /// GET /posts/{postId}/assignment
  @GET('/posts/{postId}/assignment')
  Future<ServerResponseDto<AssignmentResponse>> getAssignmentPostById(
    @Path('postId') String postId,
  );

  /// Get student's own submissions for an assignment
  /// GET /assignments/{assignmentId}/submissions/{studentId}
  @GET('/assignments/{assignmentId}/submissions')
  Future<ServerResponseDto<List<SubmissionResponseDto>>> getStudentSubmissions(
    @Path('assignmentId') String assignmentId,
    @Query('studentId') String studentId,
  );

  /// Validate if student can submit assignment (check attempt limits, etc.)
  /// POST /assignments/{assignmentId}/validate-submission
  @POST('/assignments/{assignmentId}/validate-submission')
  Future<ServerResponseDto<ValidationResponseDto>> validateAttempt(
    @Path('assignmentId') String assignmentId,
    @Body() ValidateSubmissionRequestDto request,
  );

  // ============ Teacher Endpoints ============

  /// Get all submissions for a specific post (teacher view)
  /// GET /posts/{postId}/submissions
  @GET('/posts/{postId}/submissions')
  Future<ServerResponseDto<List<SubmissionResponseDto>>> getPostSubmissions(
    @Path('postId') String postId,
  );

  /// Get a single submission by ID (teacher or student owner)
  /// GET /submissions/{id}
  @GET('/submissions/{id}')
  Future<ServerResponseDto<SubmissionResponseDto>> getSubmissionById(
    @Path('id') String submissionId,
  );

  /// Grade a submission (manual grading for open-ended or override auto-grades)
  /// PUT /submissions/{id}/grade
  @PUT('/submissions/{id}/grade')
  Future<ServerResponseDto<SubmissionResponseDto>> gradeSubmission(
    @Path('id') String submissionId,
    @Body() GradeSubmissionRequestDto request,
  );

  /// Get submission statistics for a post (teacher view)
  /// GET /posts/{postId}/submissions/statistics
  @GET('/posts/{postId}/submissions/statistics')
  Future<ServerResponseDto<SubmissionStatisticsResponseDto>>
  getSubmissionStatistics(@Path('postId') String postId);
}
