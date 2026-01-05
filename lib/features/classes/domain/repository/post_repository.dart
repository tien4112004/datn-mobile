import 'package:datn_mobile/features/classes/domain/entity/post_entity.dart';
import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';

/// Repository interface for post-related operations.
/// This defines the contract without implementation details.
abstract class PostRepository {
  /// Fetches a paginated list of posts for a specific class
  Future<List<PostEntity>> getClassPosts({
    required String classId,
    int page = 1,
    int size = 20,
    PostType? type,
    String? search,
  });

  /// Creates a new post in a class
  Future<PostEntity> createPost({
    required String classId,
    required String content,
    required PostType type,
    List<String>? attachments,
    List<String>? linkedResourceIds,
    String? linkedLessonId,
    bool? allowComments,
  });

  /// Fetches a single post by its ID
  Future<PostEntity> getPostById(String postId);

  /// Updates an existing post
  Future<PostEntity> updatePost({
    required String postId,
    String? content,
    PostType? type,
    List<String>? attachments,
    List<String>? linkedResourceIds,
    String? linkedLessonId,
    bool? isPinned,
    bool? allowComments,
  });

  /// Deletes a post by its ID
  Future<void> deletePost(String postId);

  /// Toggles the pin status of a post
  Future<PostEntity> togglePin(String postId);
}
