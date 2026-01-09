import 'dart:async';

import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:datn_mobile/features/classes/providers/post_paging_controller_pod.dart';
import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for updating an existing post
class UpdatePostController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Updates a post
  Future<void> updatePost({
    required String classId,
    required String postId,
    String? content,
    PostType? type,
    List<String>? attachments,
    List<String>? linkedResourceIds,
    String? linkedLessonId,
    bool? isPinned,
    bool? allowComments,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(postRepositoryProvider);
      await repository.updatePost(
        postId: postId,
        content: content,
        type: type,
        attachments: attachments,
        linkedResourceIds: linkedResourceIds,
        linkedLessonId: linkedLessonId,
        isPinned: isPinned,
        allowComments: allowComments,
      );

      // Refresh the posts list
      ref.invalidate(postPagingControllerPod(classId));
    });
  }

  /// Toggles the pin status of a post
  Future<void> togglePin({
    required String classId,
    required String postId,
    required bool pinned,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(postRepositoryProvider);
      await repository.togglePin(postId, pinned);

      final pagingController = ref.read(postPagingControllerPod(classId));
      pagingController.refresh();
    });
  }
}
