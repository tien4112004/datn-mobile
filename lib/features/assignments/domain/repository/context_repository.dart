import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';

/// Repository interface for context data operations.
abstract class ContextRepository {
  /// Fetches paginated list of public contexts with optional filters.
  /// Returns both the list and pagination metadata.
  Future<ContextListResult> getContexts({
    int page = 1,
    int pageSize = 20,
    String? search,
    List<String>? subject,
    List<int>? grade,
    String? sortBy,
    String? sortDirection,
  });

  /// Gets a single context by ID.
  Future<ContextEntity> getContextById(String id);

  /// Gets multiple contexts by their IDs (batch fetch).
  /// Useful for loading contexts associated with questions.
  Future<List<ContextEntity>> getContextsByIds(List<String> ids);
}

/// Result object containing the context list and pagination info.
class ContextListResult {
  final List<ContextEntity> contexts;
  final ContextPaginationInfo pagination;

  const ContextListResult({required this.contexts, required this.pagination});
}

/// Pagination information for context list.
class ContextPaginationInfo {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const ContextPaginationInfo({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  bool get hasMore => currentPage < totalPages;
}
