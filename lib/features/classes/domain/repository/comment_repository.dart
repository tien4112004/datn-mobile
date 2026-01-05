import 'package:datn_mobile/features/classes/domain/entity/comment_entity.dart';

/// Repository interface for comment-related operations.
/// This defines the contract without implementation details.
abstract class CommentRepository {
  /// Fetches all comments for a specific post
  Future<List<CommentEntity>> getPostComments(String postId);

  /// Creates a new comment on a post
  Future<CommentEntity> createComment({
    required String postId,
    required String content,
  });

  /// Fetches a single comment by its ID
  Future<CommentEntity> getCommentById(String commentId);

  /// Deletes a comment by its ID
  Future<void> deleteComment(String commentId);
}
