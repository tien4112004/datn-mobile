import 'package:datn_mobile/features/classes/data/dto/comment_create_request_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/comment_response_dto.dart';
import 'package:datn_mobile/features/classes/data/source/comment_remote_data_source.dart';
import 'package:datn_mobile/features/classes/domain/entity/comment_entity.dart';
import 'package:datn_mobile/features/classes/domain/repository/comment_repository.dart';

/// Implementation of CommentRepository that uses remote data source
class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource _remoteDataSource;

  CommentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CommentEntity>> getPostComments(String postId) async {
    final response = await _remoteDataSource.getPostComments(postId);
    final dtos = response.data ?? [];
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<CommentEntity> createComment({
    required String postId,
    required String content,
  }) async {
    final request = CommentCreateRequestDto(content: content);
    final response = await _remoteDataSource.createComment(postId, request);
    return response.data!.toEntity();
  }

  @override
  Future<CommentEntity> getCommentById(String commentId) async {
    final response = await _remoteDataSource.getCommentById(commentId);
    return response.data!.toEntity();
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _remoteDataSource.deleteComment(commentId);
  }
}
