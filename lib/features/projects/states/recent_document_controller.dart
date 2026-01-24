part of 'controller_provider.dart';

class RecentDocumentsController extends AsyncNotifier<RecentDocumentListState> {
  List<RecentDocument> get recentDocuments {
    final currentState = state.value;
    if (currentState != null) {
      return currentState.value;
    } else {
      return [];
    }
  }

  @override
  Future<RecentDocumentListState> build() async {
    try {
      final response = await ref
          .read(recentDocumentServiceProvider)
          .fetchRecentDocuments(page: 1, pageSize: 10);

      return RecentDocumentListState(response, true, false, null);
    } catch (e) {
      return RecentDocumentListState([], false, false, e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(recentDocumentServiceProvider)
          .fetchRecentDocuments(page: 1, pageSize: 10);
      return RecentDocumentListState(response, true, false, null);
    });
  }
}
