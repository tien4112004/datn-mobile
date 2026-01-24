import 'package:datn_mobile/features/classes/data/dto/pin_post_request_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/post_create_request_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/post_response_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/post_update_request_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/linked_resource_dto.dart';
import 'package:datn_mobile/features/classes/data/source/post_remote_data_source.dart';
import 'package:datn_mobile/features/classes/domain/entity/post_entity.dart';
import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:datn_mobile/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:datn_mobile/features/classes/domain/repository/post_repository.dart';

/// Implementation of PostRepository that uses remote data source
class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remoteDataSource;

  PostRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PostEntity>> getClassPosts({
    required String classId,
    int page = 1,
    int size = 20,
    PostType? type,
    String? search,
  }) async {
    final response = await _remoteDataSource.getClassPosts(
      classId,
      page: page,
      size: size,
      type: type?.apiValue,
      search: search,
    );
    final dtos = response.data ?? [];
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<PostEntity> createPost({
    required String classId,
    required String content,
    required PostType type,
    List<String>? attachments,
    List<LinkedResourceEntity>? linkedResources,
    String? linkedLessonId,
    bool? allowComments,
  }) async {
    final request = PostCreateRequestDto(
      content: content,
      type: type.apiValue,
      attachments: attachments,
      linkedResources: linkedResources?.map((e) => e.toDto()).toList(),
      linkedLessonId: linkedLessonId,
      allowComments: allowComments,
    );
    final response = await _remoteDataSource.createPost(classId, request);
    return response.data!.toEntity();
  }

  @override
  Future<PostEntity> getPostById(String postId) async {
    final response = await _remoteDataSource.getPostById(postId);
    return response.data!.toEntity();
  }

  @override
  Future<PostEntity> updatePost({
    required String postId,
    String? content,
    PostType? type,
    List<String>? attachments,
    List<LinkedResourceEntity>? linkedResources,
    String? linkedLessonId,
    bool? isPinned,
    bool? allowComments,
  }) async {
    final request = PostUpdateRequestDto(
      content: content,
      type: type?.apiValue,
      attachments: attachments,
      linkedResources: linkedResources?.map((e) => e.toDto()).toList(),
      linkedLessonId: linkedLessonId,
      isPinned: isPinned,
      allowComments: allowComments,
    );
    final response = await _remoteDataSource.updatePost(postId, request);
    return response.data!.toEntity();
  }

  @override
  Future<void> deletePost(String postId) async {
    await _remoteDataSource.deletePost(postId);
  }

  @override
  Future<PostEntity> togglePin(String postId, bool pinned) async {
    final response = await _remoteDataSource.togglePin(
      postId,
      PinPostRequestDto(pinned: pinned),
    );
    return response.data!.toEntity();
  }
}
