import 'package:AIPrimary/features/assignments/data/dto/api/context_response.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'context_remote_source.g.dart';

/// Retrofit API service for Context endpoints.
/// Base URL already contains `/api`, so we only need `/contexts`.
@RestApi()
abstract class ContextRemoteSource {
  factory ContextRemoteSource(Dio dio, {String baseUrl}) = _ContextRemoteSource;

  /// Get paginated list of public contexts with optional filters
  /// GET /contexts?bankType=public&search=...&page=...&pageSize=...
  @GET('/contexts')
  Future<ServerResponseDto<List<ContextResponse>>> getContexts({
    @Query('bankType') String bankType = 'public',
    @Query('page') int? page,
    @Query('pageSize') int? pageSize,
    @Query('search') String? search,
    @Query('subject') List<String>? subject,
    @Query('grade') List<int>? grade,
    @Query('sortBy') String? sortBy,
    @Query('sortDirection') String? sortDirection,
  });

  /// Get context by ID
  /// GET /contexts/{id}
  @GET('/contexts/{id}')
  Future<ServerResponseDto<ContextResponse>> getContextById(
    @Path('id') String id,
  );

  /// Get multiple contexts by IDs (batch fetch)
  /// POST /contexts/by-ids
  @POST('/contexts/by-ids')
  Future<ServerResponseDto<List<ContextResponse>>> getContextsByIds(
    @Body() ContextsByIdsRequest request,
  );
}

/// Request body for batch fetching contexts by IDs
class ContextsByIdsRequest {
  final List<String> ids;

  const ContextsByIdsRequest({required this.ids});

  Map<String, dynamic> toJson() => {'ids': ids};
}
