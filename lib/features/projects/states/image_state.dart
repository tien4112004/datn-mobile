part of 'image_provider.dart';

/// State class for Image feature.
class ImageState {
  final List<ImageProjectMinimal> images;
  final bool isLoadingMore;
  final String? error;

  const ImageState({
    this.images = const [],
    this.isLoadingMore = false,
    this.error,
  });

  ImageState copyWith({
    List<ImageProjectMinimal>? images,
    bool? isLoadingMore,
    String? error,
  }) {
    return ImageState(
      images: images ?? this.images,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Filter state for images
class ImageFilterState {
  final String? searchQuery;
  final String? sortOption;

  const ImageFilterState({this.searchQuery, this.sortOption});

  ImageFilterState copyWith({String? searchQuery, String? sortOption}) {
    return ImageFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
