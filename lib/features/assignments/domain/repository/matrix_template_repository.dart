import 'package:AIPrimary/features/assignments/domain/entity/matrix_template_entity.dart';

/// Repository interface for matrix template data operations.
/// Defines contract for fetching template data from various sources.
abstract class MatrixTemplateRepository {
  /// Fetches paginated list of matrix templates with optional filters.
  ///
  /// [bankType] - Required. Either 'personal' or 'public'
  /// [page] - Page number (1-indexed). Default: 1
  /// [pageSize] - Items per page. Default: 10
  /// [search] - Optional search query for template name
  /// [subject] - Optional subject code filter
  /// [grade] - Optional grade level filter
  ///
  /// Returns result object containing template list and pagination info
  Future<MatrixTemplateListResult> getMatrixTemplates({
    required String bankType,
    int page = 1,
    int pageSize = 10,
    String? search,
    String? subject,
    String? grade,
  });
}

/// Result object containing the template list and pagination info.
class MatrixTemplateListResult {
  /// List of matrix template entities
  final List<MatrixTemplateEntity> templates;

  /// Pagination metadata
  final MatrixTemplatePaginationInfo pagination;

  const MatrixTemplateListResult({
    required this.templates,
    required this.pagination,
  });

  @override
  String toString() =>
      'MatrixTemplateListResult(templates: ${templates.length}, '
      'page: ${pagination.currentPage}/${pagination.totalPages})';
}

/// Pagination information for template list.
class MatrixTemplatePaginationInfo {
  /// Current page number (1-indexed)
  final int currentPage;

  /// Number of items per page
  final int pageSize;

  /// Total number of items across all pages
  final int totalItems;

  /// Total number of pages
  final int totalPages;

  const MatrixTemplatePaginationInfo({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  /// Check if there are more pages to load
  bool get hasMore => currentPage < totalPages;

  @override
  String toString() =>
      'MatrixTemplatePaginationInfo(page: $currentPage/$totalPages, '
      'items: $totalItems, pageSize: $pageSize)';
}
