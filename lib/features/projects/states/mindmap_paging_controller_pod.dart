import 'package:AIPrimary/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:AIPrimary/features/projects/service/service_provider.dart';
import 'package:AIPrimary/features/projects/states/mindmap_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Provider for mindmap paging controller with search filter support
final mindmapPagingControllerPod =
    Provider.autoDispose<PagingController<int, MindmapMinimal>>((ref) {
      final pagingController = PagingController<int, MindmapMinimal>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) {
            return null;
          }
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) async {
          // Read current filter state on each fetch
          final currentFilterState = ref.read(mindmapFilterProvider);
          final mindmapService = ref.read(mindmapServiceProvider);
          return mindmapService.fetchMindmapMinimalsPaged(
            pageKey,
            20,
            search: currentFilterState.searchQuery?.isEmpty == true
                ? null
                : currentFilterState.searchQuery,
            sort: currentFilterState.sortOption,
          );
        },
      );

      // Listen to filter changes and refresh
      ref.listen(mindmapFilterProvider, (previous, next) {
        if (previous?.searchQuery != next.searchQuery ||
            previous?.sortOption != next.sortOption) {
          pagingController.refresh();
        }
      });

      // Clean up controller when provider is disposed
      ref.onDispose(() {
        pagingController.dispose();
      });

      return pagingController;
    });
