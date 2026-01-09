import 'package:datn_mobile/features/classes/data/dto/pin_post_request_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/post_response_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/post_create_request_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/post_update_request_dto.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'post_remote_data_source.g.dart';

/// Retrofit API client for post-related endpoints
@RestApi()
abstract class PostRemoteDataSource {
  factory PostRemoteDataSource(Dio dio, {String baseUrl}) =
      _PostRemoteDataSource;

  /// Get paginated posts for a class
  @GET('/classes/{classId}/posts')
  Future<ServerResponseDto<List<PostResponseDto>>> getClassPosts(
    @Path('classId') String classId, {
    @Query('page') int page = 1,
    @Query('size') int size = 20,
    @Query('type') String? type,
    @Query('search') String? search,
  });

  /// Create a new post
  @POST('/classes/{classId}/posts')
  Future<ServerResponseDto<PostResponseDto>> createPost(
    @Path('classId') String classId,
    @Body() PostCreateRequestDto request,
  );

  /// Get single post details
  @GET('/posts/{postId}')
  Future<ServerResponseDto<PostResponseDto>> getPostById(
    @Path('postId') String postId,
  );

  /// Update a post
  @PUT('/posts/{postId}')
  Future<ServerResponseDto<PostResponseDto>> updatePost(
    @Path('postId') String postId,
    @Body() PostUpdateRequestDto request,
  );

  /// Delete a post
  @DELETE('/posts/{postId}')
  Future<ServerResponseDto<void>> deletePost(@Path('postId') String postId);

  /// Toggle pin status
  @POST('/posts/{postId}/pin')
  Future<ServerResponseDto<PostResponseDto>> togglePin(
    @Path('postId') String postId,
    @Body() PinPostRequestDto request,
  );
}
