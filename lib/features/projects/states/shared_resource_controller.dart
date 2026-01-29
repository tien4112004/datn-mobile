part of 'controller_provider.dart';

class SharedResourcesController extends AsyncNotifier<SharedResourceListState> {
  List<SharedResource> get sharedResources {
    final currentState = state.value;
    if (currentState != null) {
      return currentState.value;
    } else {
      return [];
    }
  }

  @override
  Future<SharedResourceListState> build() async {
    try {
      final response = await ref
          .read(sharedResourceServiceProvider)
          .fetchSharedResources();

      // Small delay
      await Future.delayed(const Duration(milliseconds: 5000));

      return SharedResourceListState(response, true, false, null);
    } catch (e) {
      return SharedResourceListState([], false, false, e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(sharedResourceServiceProvider)
          .fetchSharedResources();
      return SharedResourceListState(response, true, false, null);
    });
  }
}
