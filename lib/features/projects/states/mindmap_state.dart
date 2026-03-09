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
  final GradeLevel? gradeFilter;
  final Subject? subjectFilter;
  final String? chapterFilter;

  const MindmapFilterState({
    this.searchQuery,
    this.sortOption,
    this.gradeFilter,
    this.subjectFilter,
    this.chapterFilter,
  });

  MindmapFilterState copyWith({
    Object? searchQuery = _mindmapUndefined,
    Object? sortOption = _mindmapUndefined,
    Object? gradeFilter = _mindmapUndefined,
    Object? subjectFilter = _mindmapUndefined,
    Object? chapterFilter = _mindmapUndefined,
  }) {
    return MindmapFilterState(
      searchQuery: searchQuery == _mindmapUndefined
          ? this.searchQuery
          : searchQuery as String?,
      sortOption: sortOption == _mindmapUndefined
          ? this.sortOption
          : sortOption as SortOption?,
      gradeFilter: gradeFilter == _mindmapUndefined
          ? this.gradeFilter
          : gradeFilter as GradeLevel?,
      subjectFilter: subjectFilter == _mindmapUndefined
          ? this.subjectFilter
          : subjectFilter as Subject?,
      chapterFilter: chapterFilter == _mindmapUndefined
          ? this.chapterFilter
          : chapterFilter as String?,
    );
  }

  MindmapFilterState clearFilters() {
    return MindmapFilterState(sortOption: sortOption);
  }

  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      gradeFilter != null ||
      subjectFilter != null ||
      chapterFilter != null;
}

const Object _mindmapUndefined = Object();
