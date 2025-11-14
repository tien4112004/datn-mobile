part of 'controller_provider.dart';

// Query
class PresentationsController extends AsyncNotifier<PresentationListState> {
  List<PresentationMinimal> get presentations {
    final currentState = state.value;
    if (currentState != null) {
      return currentState.value;
    } else {
      return [];
    }
  }

  @override
  Future<PresentationListState> build() async {
    try {
      final response = await ref
          .read(presentationServiceProvider)
          .fetchPresentations();

      return PresentationListState(response, true, false, null);
    } catch (e) {
      return PresentationListState([], false, false, e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(presentationServiceProvider)
          .fetchPresentations();
      return PresentationListState(response, true, false, null);
    });
  }
}

// Command
class CreatePresentationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(Presentation presentation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(createPresentationControllerProvider.notifier)
          .create(presentation);
      ref.invalidate(presentationsControllerProvider);
    });
  }
}
