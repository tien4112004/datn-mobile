import 'package:AIPrimary/features/classes/domain/entity/comment_entity.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for managing the list of comments for a specific post
class CommentsController extends AsyncNotifier<List<CommentEntity>> {
  CommentsController({required this.postId});

  final String postId;

  @override
  Future<List<CommentEntity>> build() async {
    return _fetchComments();
  }

  /// Fetches comments from the repository
  Future<List<CommentEntity>> _fetchComments() async {
    final repository = ref.read(commentRepositoryProvider);
    return repository.getPostComments(postId);
  }

  /// Refreshes the comments list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchComments);
  }
}
