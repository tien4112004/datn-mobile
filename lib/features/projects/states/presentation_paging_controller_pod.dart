import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';
import 'package:AIPrimary/features/projects/service/service_provider.dart';
import 'package:AIPrimary/features/projects/states/presentation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Provider for presentation paging controller with search filter support
final presentationPagingControllerPod =
    Provider.autoDispose<PagingController<int, PresentationMinimal>>((ref) {
      final pagingController = PagingController<int, PresentationMinimal>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) {
            return null;
          }
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) async {
          // Read current filter state on each fetch
          final currentFilterState = ref.read(presentationFilterProvider);
          final presentationService = ref.read(presentationServiceProvider);
          return presentationService.fetchPresentationMinimalsPaged(
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
      ref.listen(presentationFilterProvider, (previous, next) {
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
