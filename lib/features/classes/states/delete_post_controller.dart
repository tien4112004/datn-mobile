import 'dart:async';

import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for deleting a post
class DeletePostController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Deletes a post
  Future<void> deletePost({
    required String classId,
    required String postId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(postRepositoryProvider);
      await repository.deletePost(postId);

      // Refresh the posts list
      ref.invalidate(postsControllerProvider(classId));
    });
  }
}
