import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:datn_mobile/features/projects/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

part 'image_state.dart';

/// Provider for Image state management.
final imageProvider = AsyncNotifierProvider<ImageController, ImageState>(() {
  return ImageController();
});

/// Filter state provider for images
final imageFilterProvider = StateProvider<ImageFilterState>((ref) {
  return const ImageFilterState();
});

class ImageController extends AsyncNotifier<ImageState> {
  @override
  ImageState build() {
    return const ImageState();
  }

  /// Loads images based on filter state.
  Future<void> loadImagesWithFilter() async {
    final filterParams = ref.read(imageFilterProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(imageServiceProvider);

      final result = await service.fetchImageMinimalsPaged(
        1,
        search: filterParams.searchQuery?.isEmpty == true
            ? null
            : filterParams.searchQuery,
      );

      return ImageState(images: result);
    });
  }

  /// Loads images without filters
  Future<void> loadImages() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(imageServiceProvider);

      final result = await service.fetchImageMinimalsPaged(1);

      return ImageState(images: result);
    });
  }
}
