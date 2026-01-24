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

  const ImageFilterState({this.searchQuery});

  ImageFilterState copyWith({String? searchQuery}) {
    return ImageFilterState(searchQuery: searchQuery ?? this.searchQuery);
  }
}
