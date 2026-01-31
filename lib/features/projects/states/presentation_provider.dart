import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';
import 'package:AIPrimary/features/projects/enum/sort_option.dart';
import 'package:AIPrimary/features/projects/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

part 'presentation_state.dart';

/// Provider for Presentation state management.
final presentationProvider =
    AsyncNotifierProvider<PresentationController, PresentationState>(() {
      return PresentationController();
    });

/// Filter state provider for presentations
final presentationFilterProvider = StateProvider<PresentationFilterState>((
  ref,
) {
  return const PresentationFilterState();
});

class PresentationController extends AsyncNotifier<PresentationState> {
  @override
  PresentationState build() {
    return const PresentationState();
  }

  /// Loads presentations based on filter state.
  Future<void> loadPresentationsWithFilter() async {
    final filterParams = ref.read(presentationFilterProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(presentationServiceProvider);

      final result = await service.fetchPresentationMinimalsPaged(
        1,
        search: filterParams.searchQuery?.isEmpty == true
            ? null
            : filterParams.searchQuery,
        sort: filterParams.sortOption,
      );

      return PresentationState(presentations: result);
    });
  }

  /// Loads presentations without filters
  Future<void> loadPresentations() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(presentationServiceProvider);

      final result = await service.fetchPresentationMinimalsPaged(1);

      return PresentationState(presentations: result);
    });
  }
}
