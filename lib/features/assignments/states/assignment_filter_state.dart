import 'package:AIPrimary/shared/models/cms_enums.dart';

/// State class for assignment filters.
/// Follows the same pattern as Question Bank filters.
class AssignmentFilterState {
  final String? searchQuery;
  final GradeLevel? gradeLevelFilter;
  final Subject? subjectFilter;

  const AssignmentFilterState({
    this.searchQuery,
    this.gradeLevelFilter,
    this.subjectFilter,
  });

  /// Get filter parameters for API calls
  AssignmentFilterParams getFilterParams() {
    return AssignmentFilterParams(
      search: searchQuery,
      gradeLevel: gradeLevelFilter?.apiValue,
      subject: subjectFilter?.apiValue,
    );
  }

  /// Create a copy with updated values
  AssignmentFilterState copyWith({
    Object? searchQuery = _undefinedAssignment,
    Object? gradeLevelFilter = _undefinedAssignment,
    Object? subjectFilter = _undefinedAssignment,
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
      subjectFilter != null;

  /// Get count of active filters (for UI badge)
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (gradeLevelFilter != null) count++;
    if (subjectFilter != null) count++;
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

  const AssignmentFilterParams({this.search, this.gradeLevel, this.subject});
}
