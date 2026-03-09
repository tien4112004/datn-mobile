import 'package:AIPrimary/shared/models/cms_enums.dart';

/// State class for assignment filters.
/// Follows the same pattern as Question Bank filters.
class AssignmentFilterState {
  final String? searchQuery;
  final GradeLevel? gradeLevelFilter;
  final Subject? subjectFilter;
  final String? chapterFilter;

  const AssignmentFilterState({
    this.searchQuery,
    this.gradeLevelFilter,
    this.subjectFilter,
    this.chapterFilter,
  });

  /// Get filter parameters for API calls
  AssignmentFilterParams getFilterParams() {
    return AssignmentFilterParams(
      search: searchQuery,
      gradeLevel: gradeLevelFilter?.apiValue,
      subject: subjectFilter?.apiValue,
      chapter: chapterFilter,
    );
  }

  /// Create a copy with updated values
  AssignmentFilterState copyWith({
    Object? searchQuery = _undefinedAssignment,
    Object? gradeLevelFilter = _undefinedAssignment,
    Object? subjectFilter = _undefinedAssignment,
    Object? chapterFilter = _undefinedAssignment,
  }) {
    return AssignmentFilterState(
      searchQuery: searchQuery == _undefinedAssignment
          ? this.searchQuery
          : searchQuery as String?,
      gradeLevelFilter: gradeLevelFilter == _undefinedAssignment
          ? this.gradeLevelFilter
          : gradeLevelFilter as GradeLevel?,
      subjectFilter: subjectFilter == _undefinedAssignment
          ? this.subjectFilter
          : subjectFilter as Subject?,
      chapterFilter: chapterFilter == _undefinedAssignment
          ? this.chapterFilter
          : chapterFilter as String?,
    );
  }

  /// Clear all filters
  AssignmentFilterState clearFilters() {
    return const AssignmentFilterState();
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      searchQuery != null && searchQuery!.isNotEmpty ||
      gradeLevelFilter != null ||
      subjectFilter != null ||
      chapterFilter != null;

  /// Get count of active filters (for UI badge)
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (gradeLevelFilter != null) count++;
    if (subjectFilter != null) count++;
    if (chapterFilter != null) count++;
    return count;
  }
}

// Sentinel value to distinguish between "not provided" and "null"
const Object _undefinedAssignment = Object();

/// Parameters for API calls
class AssignmentFilterParams {
  final String? search;
  final String? gradeLevel;
  final String? subject;
  final String? chapter;

  const AssignmentFilterParams({
    this.search,
    this.gradeLevel,
    this.subject,
    this.chapter,
  });
}
