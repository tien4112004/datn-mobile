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
  final GradeLevel? gradeFilter;
  final Subject? subjectFilter;
  final String? chapterFilter;

  const PresentationFilterState({
    this.searchQuery,
    this.sortOption,
    this.gradeFilter,
    this.subjectFilter,
    this.chapterFilter,
  });

  PresentationFilterState copyWith({
    Object? searchQuery = _undefined,
    Object? sortOption = _undefined,
    Object? gradeFilter = _undefined,
    Object? subjectFilter = _undefined,
    Object? chapterFilter = _undefined,
  }) {
    return PresentationFilterState(
      searchQuery: searchQuery == _undefined
          ? this.searchQuery
          : searchQuery as String?,
      sortOption: sortOption == _undefined
          ? this.sortOption
          : sortOption as SortOption?,
      gradeFilter: gradeFilter == _undefined
          ? this.gradeFilter
          : gradeFilter as GradeLevel?,
      subjectFilter: subjectFilter == _undefined
          ? this.subjectFilter
          : subjectFilter as Subject?,
      chapterFilter: chapterFilter == _undefined
          ? this.chapterFilter
          : chapterFilter as String?,
    );
  }

  PresentationFilterState clearFilters() {
    return PresentationFilterState(sortOption: sortOption);
  }

  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      gradeFilter != null ||
      subjectFilter != null ||
      chapterFilter != null;
}

const Object _undefined = Object();
