import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';

/// State class for assignment filters
class AssignmentFilterState {
  final AssignmentStatus? statusFilter;
  final GradeLevel? gradeLevelFilter;
  final String? topicFilter;

  const AssignmentFilterState({
    this.statusFilter,
    this.gradeLevelFilter,
    this.topicFilter,
  });

  /// Get filter parameters for API calls
  AssignmentFilterParams getFilterParams() {
    return AssignmentFilterParams(
      status: statusFilter,
      gradeLevel: gradeLevelFilter?.apiValue,
      topic: topicFilter,
    );
  }

  /// Create a copy with updated values
  AssignmentFilterState copyWith({
    Object? statusFilter = _undefinedAssignment,
    Object? gradeLevelFilter = _undefinedAssignment,
    Object? topicFilter = _undefinedAssignment,
  }) {
    return AssignmentFilterState(
      statusFilter: statusFilter == _undefinedAssignment
          ? this.statusFilter
          : statusFilter as AssignmentStatus?,
      gradeLevelFilter: gradeLevelFilter == _undefinedAssignment
          ? this.gradeLevelFilter
          : gradeLevelFilter as GradeLevel?,
      topicFilter: topicFilter == _undefinedAssignment
          ? this.topicFilter
          : topicFilter as String?,
    );
  }

  /// Clear all filters
  AssignmentFilterState clearFilters() {
    return const AssignmentFilterState();
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      statusFilter != null || gradeLevelFilter != null || topicFilter != null;
}

// Sentinel value to distinguish between "not provided" and "null"
const Object _undefinedAssignment = Object();

/// Parameters for API calls
class AssignmentFilterParams {
  final AssignmentStatus? status;
  final String? gradeLevel;
  final String? topic;

  const AssignmentFilterParams({this.status, this.gradeLevel, this.topic});
}
