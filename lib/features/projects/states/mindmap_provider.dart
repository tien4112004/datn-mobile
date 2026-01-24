import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/enum/sort_option.dart';
import 'package:datn_mobile/features/projects/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

part 'mindmap_state.dart';

/// Provider for Mindmap state management.
final mindmapProvider = AsyncNotifierProvider<MindmapController, MindmapState>(
  () {
    return MindmapController();
  },
);

/// Filter state provider for mindmaps
final mindmapFilterProvider = StateProvider<MindmapFilterState>((ref) {
  return const MindmapFilterState();
});

class MindmapController extends AsyncNotifier<MindmapState> {
  @override
  MindmapState build() {
    return const MindmapState();
  }

  /// Loads mindmaps based on filter state.
  Future<void> loadMindmapsWithFilter() async {
    final filterParams = ref.read(mindmapFilterProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(mindmapServiceProvider);

      final result = await service.fetchMindmapMinimalsPaged(
        1,
        10,
        search: filterParams.searchQuery?.isEmpty == true
            ? null
            : filterParams.searchQuery,
        sort: filterParams.sortOption,
      );

      return MindmapState(mindmaps: result);
    });
  }

  /// Loads mindmaps without filters
  Future<void> loadMindmaps() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(mindmapServiceProvider);

      final result = await service.fetchMindmapMinimalsPaged(1, 10);

      return MindmapState(mindmaps: result);
    });
  }
}
