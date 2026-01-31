import 'package:AIPrimary/features/classes/data/repository/comment_repository_impl.dart';
import 'package:AIPrimary/features/classes/data/repository/post_repository_impl.dart';
import 'package:AIPrimary/features/classes/data/source/comment_remote_data_source.dart';
import 'package:AIPrimary/features/classes/data/source/post_remote_data_source.dart';
import 'package:AIPrimary/features/classes/domain/entity/comment_entity.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_entity.dart';
import 'package:AIPrimary/features/classes/domain/repository/comment_repository.dart';
import 'package:AIPrimary/features/classes/domain/repository/post_repository.dart';
import 'package:AIPrimary/features/classes/states/comments_controller.dart';
import 'package:AIPrimary/features/classes/states/create_comment_controller.dart';
import 'package:AIPrimary/features/classes/states/create_post_controller.dart';
import 'package:AIPrimary/features/classes/states/delete_comment_controller.dart';
import 'package:AIPrimary/features/classes/states/delete_post_controller.dart';
import 'package:AIPrimary/features/classes/states/posts_controller.dart';
import 'package:AIPrimary/features/classes/states/update_post_controller.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Data Source Providers
/// Provider for post remote data source
final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  final dio = ref.watch(dioPod);
  return PostRemoteDataSource(dio);
});

/// Provider for comment remote data source
final commentRemoteDataSourceProvider = Provider<CommentRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioPod);
  return CommentRemoteDataSource(dio);
});

// Repository Providers
/// Provider for post repository
final postRepositoryProvider = Provider<PostRepository>((ref) {
  final dataSource = ref.watch(postRemoteDataSourceProvider);
  return PostRepositoryImpl(dataSource);
});

/// Provider for comment repository
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final dataSource = ref.watch(commentRemoteDataSourceProvider);
  return CommentRepositoryImpl(dataSource);
});
// Controller Providers

/// Provider for posts list controller (family by classId)
final postsControllerProvider =
    AsyncNotifierProvider.family<PostsController, List<PostEntity>, String>(
      (classId) => PostsController(classId: classId),
    );

/// Provider for comments list controller (family by postId)
final commentsControllerProvider =
    AsyncNotifierProvider.family<
      CommentsController,
      List<CommentEntity>,
      String
    >((postId) => CommentsController(postId: postId));

/// Provider for create post controller
final createPostControllerProvider =
    AsyncNotifierProvider<CreatePostController, void>(CreatePostController.new);

/// Provider for update post controller
final updatePostControllerProvider =
    AsyncNotifierProvider<UpdatePostController, void>(UpdatePostController.new);

/// Provider for delete post controller
final deletePostControllerProvider =
    AsyncNotifierProvider<DeletePostController, void>(DeletePostController.new);

/// Provider for create comment controller
final createCommentControllerProvider =
    AsyncNotifierProvider<CreateCommentController, void>(
      CreateCommentController.new,
    );

/// Provider for delete comment controller
final deleteCommentControllerProvider =
    AsyncNotifierProvider<DeleteCommentController, void>(
      DeleteCommentController.new,
    );

final grantFocusStateProvider = StateProvider<bool>((ref) => false);
