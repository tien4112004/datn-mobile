part of 'controller_provider.dart';

// Query
class MindmapsController extends AsyncNotifier<MindmapListState> {
  List<MindmapMinimal> get mindmaps {
    final currentState = state.value;
    if (currentState != null) {
      return currentState.value;
    } else {
      return [];
    }
  }

  @override
  Future<MindmapListState> build() async {
    try {
      final response = await ref.read(mindmapServiceProvider).fetchMindmaps();

      return MindmapListState(response, true, false, null);
    } catch (e) {
      return MindmapListState([], false, false, e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref.read(mindmapServiceProvider).fetchMindmaps();
      return MindmapListState(response, true, false, null);
    });
  }
}
