import 'package:AIPrimary/features/assignments/data/dto/api/assignment_create_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_update_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/generate_assignment_from_matrix_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/generate_full_assignment_request.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_draft_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';

/// Repository interface for assignment data operations.
/// Matches the API specification from ASSIGNMENT_API_DOCS.md
abstract class AssignmentRepository {
  /// Fetches paginated list of assignments with optional search.
  /// Returns both the list and pagination metadata.
  Future<AssignmentListResult> getAssignments({
    int page = 1,
    int size = 10,
    String? search,
  });

  /// Gets a single assignment by ID.
  Future<AssignmentEntity> getAssignmentById(String id);

  /// Creates a new assignment.
  Future<AssignmentEntity> createAssignment(AssignmentCreateRequest request);

  /// Updates an existing assignment.
  Future<AssignmentEntity> updateAssignment(
    String id,
    AssignmentUpdateRequest request,
  );

  /// Deletes an assignment.
  Future<void> deleteAssignment(String id);

  /// Gets an assignment by post ID.
  Future<AssignmentEntity> getAssignmentByPostId(String postId);

  /// Generates an assignment by picking questions from the question bank.
  Future<AssignmentDraftEntity> generateAssignmentFromMatrix(
    GenerateAssignmentFromMatrixRequest request,
  );

  /// Generates an assignment with AI creating all questions from scratch.
  Future<AssignmentDraftEntity> generateFullAssignment(
    GenerateFullAssignmentRequest request,
  );
}

/// Result object containing the assignment list and pagination info.
class AssignmentListResult {
  final List<AssignmentEntity> assignments;
  final PaginationInfo pagination;

  const AssignmentListResult({
    required this.assignments,
    required this.pagination,
  });
}

/// Pagination information from the API response.
class PaginationInfo {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const PaginationInfo({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });
}
