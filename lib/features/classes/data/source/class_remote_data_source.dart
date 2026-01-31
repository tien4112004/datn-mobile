import 'package:AIPrimary/features/classes/data/dto/class_create_request_dto.dart';
import 'package:AIPrimary/features/classes/data/dto/class_list_response_dto.dart';
import 'package:AIPrimary/features/classes/data/dto/class_response_dto.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'class_remote_data_source.g.dart';

/// Remote data source for class-related API calls.
@RestApi()
abstract class ClassRemoteDataSource {
  factory ClassRemoteDataSource(Dio dio, {String baseUrl}) =
      _ClassRemoteDataSource;

  /// Fetches list of classes from the API.
  @GET('/classes')
  Future<ServerResponseDto<List<ClassListResponseDto>>> getClasses({
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 20,
    @Query('search') String? search,
    @Query('sort') String? sort,
    @Query('isActive') bool? isActive,
  });

  /// Creates a new class.
  @POST('/classes')
  Future<ServerResponseDto<ClassResponseDto>> createClass(
    @Body() ClassCreateRequestDto request,
  );

  /// Gets a single class by ID.
  @GET('/classes/{classId}')
  Future<ServerResponseDto<ClassResponseDto>> getClassById(
    @Path('classId') String classId,
  );

  /// Updates an existing class.
  @PUT('/classes/{classId}')
  Future<ServerResponseDto<ClassResponseDto>> updateClass(
    @Path('classId') String classId,
    @Body() Map<String, dynamic> request,
  );
}
