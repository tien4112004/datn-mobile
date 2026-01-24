part of 'presentation_provider.dart';

/// State class for Presentation feature.
class PresentationState {
  final List<PresentationMinimal> presentations;
  final bool isLoadingMore;
  final String? error;

  const PresentationState({
    this.presentations = const [],
    this.isLoadingMore = false,
    this.error,
  });

  PresentationState copyWith({
    List<PresentationMinimal>? presentations,
    bool? isLoadingMore,
    String? error,
  }) {
    return PresentationState(
      presentations: presentations ?? this.presentations,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Filter state for presentations
class PresentationFilterState {
  final String? searchQuery;
  final SortOption? sortOption;

  const PresentationFilterState({this.searchQuery, this.sortOption});

  PresentationFilterState copyWith({
    String? searchQuery,
    SortOption? sortOption,
  }) {
    return PresentationFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
