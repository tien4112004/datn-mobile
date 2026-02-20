import 'package:AIPrimary/features/assignments/data/dto/api/matrix_template_response.dart';
import 'package:AIPrimary/features/assignments/data/source/matrix_template_remote_source.dart';
import 'package:AIPrimary/features/assignments/domain/repository/matrix_template_repository.dart';

/// Implementation of MatrixTemplateRepository using remote API source.
/// Handles data fetching, DTO-to-entity mapping, and pagination metadata extraction.
class MatrixTemplateRepositoryImpl implements MatrixTemplateRepository {
  final MatrixTemplateRemoteSource _remoteSource;

  MatrixTemplateRepositoryImpl(this._remoteSource);

  @override
  Future<MatrixTemplateListResult> getMatrixTemplates({
    required String bankType,
    int page = 1,
    int pageSize = 10,
    String? search,
    String? subject,
    String? grade,
  }) async {
    // Fetch from API
    final response = await _remoteSource.getMatrixTemplates(
      bankType: bankType,
      page: page,
      pageSize: pageSize,
      search: search,
      subject: subject,
      grade: grade,
    );

    // Map DTOs to domain entities
    final templates =
        response.data?.map((dto) => dto.toEntity()).toList() ?? [];

    // Extract pagination info from server response
    final pagination = MatrixTemplatePaginationInfo(
      currentPage: response.pagination?.page ?? page,
      pageSize: response.pagination?.size ?? pageSize,
      totalItems: response.pagination?.totalElements ?? 0,
      totalPages: response.pagination?.totalPages ?? 0,
    );

    return MatrixTemplateListResult(
      templates: templates,
      pagination: pagination,
    );
  }
}
