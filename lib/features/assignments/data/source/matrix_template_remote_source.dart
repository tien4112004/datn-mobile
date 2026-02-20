import 'package:AIPrimary/features/assignments/data/dto/api/matrix_template_response.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'matrix_template_remote_source.g.dart';

/// Retrofit API service for Matrix Template endpoints.
/// Provides access to template CRUD operations via REST API.
@RestApi()
abstract class MatrixTemplateRemoteSource {
  factory MatrixTemplateRemoteSource(Dio dio, {String baseUrl}) =
      _MatrixTemplateRemoteSource;

  /// Get paginated list of matrix templates with filtering options.
  ///
  /// [bankType] - Required. Either 'personal' (user's templates) or 'public' (shared templates)
  /// [page] - Page number (1-indexed). Default: 1
  /// [pageSize] - Items per page. Default: 10
  /// [search] - Optional search query for template name
  /// [subject] - Optional subject code filter (e.g., 'T', 'TV')
  /// [grade] - Optional grade level filter (e.g., '1', '2', '3')
  ///
  /// Returns server response with list of templates and pagination metadata
  @GET('/matrix-templates')
  Future<ServerResponseDto<List<MatrixTemplateResponse>>> getMatrixTemplates({
    @Query('bankType') required String bankType,
    @Query('page') int? page,
    @Query('pageSize') int? pageSize,
    @Query('search') String? search,
    @Query('subject') String? subject,
    @Query('grade') String? grade,
  });
}
