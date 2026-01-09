import 'package:datn_mobile/features/classes/data/dto/comment_response_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/comment_create_request_dto.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'comment_remote_data_source.g.dart';

/// Retrofit API client for comment-related endpoints
@RestApi()
abstract class CommentRemoteDataSource {
  factory CommentRemoteDataSource(Dio dio, {String baseUrl}) =
      _CommentRemoteDataSource;

  /// Get all comments for a post
  @GET('/posts/{postId}/comments')
  Future<ServerResponseDto<List<CommentResponseDto>>> getPostComments(
    @Path('postId') String postId,
  );

  /// Create a comment
  @POST('/posts/{postId}/comments')
  Future<ServerResponseDto<CommentResponseDto>> createComment(
    @Path('postId') String postId,
    @Body() CommentCreateRequestDto request,
  );

  /// Get single comment
  @GET('/comments/{commentId}')
  Future<ServerResponseDto<CommentResponseDto>> getCommentById(
    @Path('commentId') String commentId,
  );

  /// Delete a comment
  @DELETE('/comments/{commentId}')
  Future<ServerResponseDto<void>> deleteComment(
    @Path('commentId') String commentId,
  );
}
