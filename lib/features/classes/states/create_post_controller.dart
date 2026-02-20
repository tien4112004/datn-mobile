import 'dart:async';

import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
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
    String? assignmentId,
    DateTime? dueDate,
    bool? allowComments,
    // Assignment settings (only for Homework type posts)
    int? maxSubmissions,
    bool? allowRetake,
    bool? showCorrectAnswers,
    bool? showScoreImmediately,
    double? passingScore,
    DateTime? availableFrom,
    DateTime? availableUntil,
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
        assignmentId: assignmentId,
        dueDate: dueDate,
        allowComments: allowComments,
        maxSubmissions: maxSubmissions,
        allowRetake: allowRetake,
        showCorrectAnswers: showCorrectAnswers,
        showScoreImmediately: showScoreImmediately,
        passingScore: passingScore,
        availableFrom: availableFrom,
        availableUntil: availableUntil,
      );

      // Refresh the posts list
      ref.invalidate(postsControllerProvider(classId));
    });
  }
}
