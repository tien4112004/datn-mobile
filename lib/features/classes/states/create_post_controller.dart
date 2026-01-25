import 'dart:async';

import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:datn_mobile/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller for creating a new post
class CreatePostController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Creates a new post
  Future<void> createPost({
    required String classId,
    required String content,
    required PostType type,
    List<String>? attachments,
    List<LinkedResourceEntity>? linkedResources,
    String? linkedLessonId,
    DateTime? dueDate,
    bool? allowComments,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(postRepositoryProvider);
      await repository.createPost(
        classId: classId,
        content: content,
        type: type,
        attachments: attachments,
        linkedResources: linkedResources,
        linkedLessonId: linkedLessonId,
        dueDate: dueDate,
        allowComments: allowComments,
      );

      // Refresh the posts list
      ref.invalidate(postsControllerProvider(classId));
    });
  }
}
