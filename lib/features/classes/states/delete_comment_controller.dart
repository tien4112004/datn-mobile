import 'dart:async';

import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for deleting a comment
class DeleteCommentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Deletes a comment
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(commentRepositoryProvider);
      await repository.deleteComment(commentId);

      // Refresh the comments list
      ref.invalidate(commentsControllerProvider(postId));
    });
  }
}
