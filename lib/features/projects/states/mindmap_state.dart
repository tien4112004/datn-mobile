part of 'mindmap_provider.dart';

/// State class for Mindmap feature.
class MindmapState {
  final List<MindmapMinimal> mindmaps;
  final bool isLoadingMore;
  final String? error;

  const MindmapState({
    this.mindmaps = const [],
    this.isLoadingMore = false,
    this.error,
  });

  MindmapState copyWith({
    List<MindmapMinimal>? mindmaps,
    bool? isLoadingMore,
    String? error,
  }) {
    return MindmapState(
      mindmaps: mindmaps ?? this.mindmaps,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

/// Filter state for mindmaps
class MindmapFilterState {
  final String? searchQuery;
  final SortOption? sortOption;

  const MindmapFilterState({this.searchQuery, this.sortOption});

  MindmapFilterState copyWith({String? searchQuery, SortOption? sortOption}) {
    return MindmapFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
