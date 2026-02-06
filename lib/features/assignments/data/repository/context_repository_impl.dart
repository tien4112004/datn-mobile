import 'package:AIPrimary/features/assignments/data/dto/api/context_response.dart';
import 'package:AIPrimary/features/assignments/data/source/context_remote_source.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/domain/repository/context_repository.dart';

/// Implementation of ContextRepository using remote API source.
class ContextRepositoryImpl implements ContextRepository {
  final ContextRemoteSource _remoteSource;

  ContextRepositoryImpl(this._remoteSource);

  @override
  Future<ContextListResult> getContexts({
    int page = 1,
    int pageSize = 20,
    String? search,
    List<String>? subject,
    List<int>? grade,
    String? sortBy,
    String? sortDirection,
  }) async {
    final response = await _remoteSource.getContexts(
      bankType: 'public',
      page: page,
      pageSize: pageSize,
      search: search,
      subject: subject,
      grade: grade,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );

    // Map response data to domain entities
    final contexts = response.data?.map((dto) => dto.toEntity()).toList() ?? [];

    // Extract pagination info
    final pagination = ContextPaginationInfo(
      currentPage: response.pagination?.page ?? page,
      pageSize: response.pagination?.size ?? pageSize,
      totalItems: response.pagination?.totalElements ?? 0,
      totalPages: response.pagination?.totalPages ?? 0,
    );

    return ContextListResult(contexts: contexts, pagination: pagination);
  }

  @override
  Future<ContextEntity> getContextById(String id) async {
    final response = await _remoteSource.getContextById(id);

    if (response.data == null) {
      throw Exception('Context not found');
    }

    return response.data!.toEntity();
  }

  @override
  Future<List<ContextEntity>> getContextsByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }

    final response = await _remoteSource.getContextsByIds(
      ContextsByIdsRequest(ids: ids),
    );

    return response.data?.map((dto) => dto.toEntity()).toList() ?? [];
  }
}
