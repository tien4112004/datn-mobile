import 'package:AIPrimary/features/assignments/data/dto/api/assignment_create_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_draft_response.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_response.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_update_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/generate_assignment_from_matrix_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/generate_full_assignment_request.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'assignment_remote_source.g.dart';

@RestApi()
abstract class AssignmentRemoteSource {
  factory AssignmentRemoteSource(Dio dio, {String baseUrl}) =
      _AssignmentRemoteSource;

  /// Create a new assignment
  /// POST /assignments
  @POST('/assignments')
  Future<ServerResponseDto<AssignmentResponse>> createAssignment(
    @Body() AssignmentCreateRequest request,
  );

  /// Get paginated list of assignments with optional search
  /// GET /assignments
  @GET('/assignments')
  Future<ServerResponseDto<List<AssignmentResponse>>> getAssignments(
    @Query('page') int page,
    @Query('size') int size,
    @Query('search') String? search,
  );

  /// Get assignment by ID
  /// GET /assignments/{id}
  @GET('/assignments/{id}')
  Future<ServerResponseDto<AssignmentResponse>> getAssignmentById(
    @Path('id') String id,
  );

  /// Update an existing assignment
  /// PUT /assignments/{id}
  @PUT('/assignments/{id}')
  Future<ServerResponseDto<AssignmentResponse>> updateAssignment(
    @Path('id') String id,
    @Body() AssignmentUpdateRequest request,
  );

  /// Delete an assignment
  /// DELETE /assignments/{id}
  @DELETE('/assignments/{id}')
  Future<ServerResponseDto<void>> deleteAssignment(@Path('id') String id);

  /// Get assignment by post ID
  /// GET /posts/{postId}/assignment
  @GET('/posts/{postId}/assignment')
  Future<ServerResponseDto<AssignmentResponse>> getAssignmentByPostId(
    @Path('postId') String postId,
  );

  /// Generate assignment by picking questions from the question bank per matrix.
  /// POST /assignments/generate-from-matrix
  @POST('/assignments/generate-from-matrix')
  Future<ServerResponseDto<AssignmentDraftResponse>> generateAssignmentFromMatrix(
    @Body() GenerateAssignmentFromMatrixRequest request,
  );

  /// Generate assignment with AI creating all questions from scratch.
  /// POST /assignments/generate-full-assignment
  @POST('/assignments/generate-full-assignment')
  Future<ServerResponseDto<AssignmentDraftResponse>> generateFullAssignment(
    @Body() GenerateFullAssignmentRequest request,
  );
}
