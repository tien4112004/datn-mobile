import 'dart:async';

import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for creating a new comment
class CreateCommentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Creates a new comment
  Future<void> createComment({
    required String postId,
    required String content,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(commentRepositoryProvider);
      await repository.createComment(postId: postId, content: content);

      // Refresh the comments list
      ref.invalidate(commentsControllerProvider(postId));

      // Also refresh the posts list to update comment count
      // Note: We'll need to pass classId for this, or we can just refresh all posts
    });
  }
}
