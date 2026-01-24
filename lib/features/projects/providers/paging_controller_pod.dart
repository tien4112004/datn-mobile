import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';
import 'package:datn_mobile/features/projects/enum/sort_option.dart';
import 'package:datn_mobile/features/projects/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final pagingControllerPod = Provider.autoDispose
    .family<PagingController<int, PresentationMinimal>, (String?, SortOption?)>(
      (ref, params) {
        final searchQuery = params.$1;
        final sort = params.$2;

        late final pagingController =
            PagingController<int, PresentationMinimal>(
              getNextPageKey: (state) {
                if (state.lastPageIsEmpty) {
                  return null;
                }
                return state.nextIntPageKey;
              },
              fetchPage: (pageKey) => ref
                  .read(presentationServiceProvider)
                  .fetchPresentationMinimalsPaged(
                    pageKey,
                    search: searchQuery,
                    sort: sort,
                  ),
            );
        return pagingController;
      },
    );

final imagePagingControllerPod = Provider.autoDispose
    .family<PagingController<int, ImageProjectMinimal>, String?>((
      ref,
      searchQuery,
    ) {
      late final pagingController = PagingController<int, ImageProjectMinimal>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) {
            return null;
          }
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) => ref
            .read(imageServiceProvider)
            .fetchImageMinimalsPaged(pageKey, search: searchQuery),
      );
      return pagingController;
    });

final mindmapPagingControllerPod = Provider.autoDispose
    .family<PagingController<int, MindmapMinimal>, (String?, SortOption?)>((
      ref,
      params,
    ) {
      final searchQuery = params.$1;
      final sort = params.$2;

      late final pagingController = PagingController<int, MindmapMinimal>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) {
            return null;
          }
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) => ref
            .read(mindmapServiceProvider)
            .fetchMindmapMinimalsPaged(
              pageKey,
              10,
              search: searchQuery,
              sort: sort,
            ),
      );
      return pagingController;
    });

final mindmapsPagingControllerPod =
    Provider.autoDispose<PagingController<int, MindmapMinimal>>((ref) {
      late final pagingController = PagingController<int, MindmapMinimal>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) {
            return null;
          }
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) => ref
            .read(mindmapServiceProvider)
            .fetchMindmapMinimalsPaged(pageKey, 10),
      );
      return pagingController;
    });
