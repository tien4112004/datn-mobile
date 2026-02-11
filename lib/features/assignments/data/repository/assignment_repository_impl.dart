import 'package:AIPrimary/features/assignments/data/dto/api/assignment_create_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_response.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_update_request.dart';
import 'package:AIPrimary/features/assignments/data/source/assignment_remote_source.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/domain/repository/assignment_repository.dart';

/// Implementation of AssignmentRepository using remote API source.
/// Maps DTOs to domain entities according to ASSIGNMENT_API_DOCS.md
class AssignmentRepositoryImpl implements AssignmentRepository {
  final AssignmentRemoteSource _remoteSource;

  AssignmentRepositoryImpl(this._remoteSource);

  @override
  Future<AssignmentListResult> getAssignments({
    int page = 1,
    int size = 10,
    String? search,
  }) async {
    final response = await _remoteSource.getAssignments(page, size, search);

    // Map response data to domain entities
    final assignments =
        response.data?.map((dto) => dto.toEntity()).toList() ?? [];

    // Extract pagination info
    final pagination = PaginationInfo(
      currentPage: response.pagination?.page ?? page,
      pageSize: response.pagination?.size ?? size,
      totalItems: response.pagination?.totalElements ?? 0,
      totalPages: response.pagination?.totalPages ?? 0,
    );

    return AssignmentListResult(
      assignments: assignments,
      pagination: pagination,
    );
  }

  @override
  Future<AssignmentEntity> getAssignmentById(String id) async {
    final response = await _remoteSource.getAssignmentById(id);

    if (response.data == null) {
      throw Exception('Assignment not found');
    }

    return response.data!.toEntity();
  }

  @override
  Future<AssignmentEntity> createAssignment(
    AssignmentCreateRequest request,
  ) async {
    final response = await _remoteSource.createAssignment(request);

    if (response.data == null) {
      throw Exception('Failed to create assignment');
    }

    return response.data!.toEntity();
  }

  @override
  Future<AssignmentEntity> updateAssignment(
    String id,
    AssignmentUpdateRequest request,
  ) async {
    final response = await _remoteSource.updateAssignment(id, request);

    if (response.data == null) {
      throw Exception('Failed to update assignment');
    }

    return response.data!.toEntity();
  }

  @override
  Future<void> deleteAssignment(String id) async {
    await _remoteSource.deleteAssignment(id);
  }

  @override
  Future<AssignmentEntity> getAssignmentByPostId(String postId) async {
    final response = await _remoteSource.getAssignmentByPostId(postId);

    if (response.data == null) {
      throw Exception('Assignment not found for post');
    }

    return response.data!.toEntity();
  }
}
