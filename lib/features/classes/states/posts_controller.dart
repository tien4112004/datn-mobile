import 'package:datn_mobile/features/classes/domain/entity/post_entity.dart';
import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for managing the list of posts for a specific class
class PostsController extends AsyncNotifier<List<PostEntity>> {
  PostsController({required this.classId});

  final String classId;

  int _currentPage = 1;
  bool _hasMore = true;

  @override
  Future<List<PostEntity>> build() async {
    return _fetchPosts();
  }

  /// Fetches posts from the repository
  Future<List<PostEntity>> _fetchPosts() async {
    final repository = ref.read(postRepositoryProvider);
    return repository.getClassPosts(
      classId: classId,
      page: _currentPage,
      size: 20,
    );
  }

  /// Refreshes the posts list
  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPosts);
  }

  /// Loads more posts for pagination
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    state.whenData((currentPosts) async {
      _currentPage++;

      try {
        final repository = ref.read(postRepositoryProvider);
        final newPosts = await repository.getClassPosts(
          classId: classId,
          page: _currentPage,
          size: 20,
        );

        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          state = AsyncValue.data([...currentPosts, ...newPosts]);
        }
      } catch (e, stack) {
        // Revert page increment on error
        _currentPage--;
        state = AsyncValue.error(e, stack);
      }
    });
  }

  /// Checks if there are more posts to load
  bool get hasMore => _hasMore;

  /// Gets the current page number
  int get currentPage => _currentPage;
}
