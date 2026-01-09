import 'package:datn_mobile/features/classes/domain/entity/post_entity.dart';
import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Provider for post paging controller (family by classId)
final postPagingControllerPod = Provider.autoDispose
    .family<PagingController<int, PostEntity>, String>((ref, classId) {
      final pagingController = PagingController<int, PostEntity>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) {
            return null;
          }
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) async {
          final repository = ref.read(postRepositoryProvider);
          return repository.getClassPosts(
            classId: classId,
            page: pageKey,
            size: 20,
          );
        },
      );

      // Clean up controller when provider is disposed
      ref.onDispose(() {
        pagingController.dispose();
      });

      return pagingController;
    });
