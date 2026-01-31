import 'package:AIPrimary/features/projects/domain/entity/image_project_minimal.dart';
import 'package:AIPrimary/features/projects/service/service_provider.dart';
import 'package:AIPrimary/features/projects/states/image_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Provider for image paging controller with search filter support
final imagePagingControllerPod =
    Provider.autoDispose<PagingController<int, ImageProjectMinimal>>((ref) {
      // Don't watch here - read once to get initial state
      final initialFilterState = ref.read(imageFilterProvider);

      final pagingController = PagingController<int, ImageProjectMinimal>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) {
            return null;
          }
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) async {
          // Read current filter state on each fetch
          final currentFilterState = ref.read(imageFilterProvider);
          final imageService = ref.read(imageServiceProvider);
          return imageService.fetchImageMinimalsPaged(
            pageKey,
            pageSize: 20,
            search: currentFilterState.searchQuery?.isEmpty == true
                ? null
                : currentFilterState.searchQuery,
            sort: currentFilterState.sortOption,
          );
        },
      );

      // Listen to filter changes and refresh
      ref.listen(imageFilterProvider, (previous, next) {
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
