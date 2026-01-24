part of 'repository_provider.dart';

class RecentDocumentRepositoryImpl implements RecentDocumentRepository {
  final ProjectsRemoteSource _remoteSource;

  RecentDocumentRepositoryImpl(this._remoteSource);

  @override
  Future<List<RecentDocument>> fetchRecentDocuments({
    int page = 1,
    int pageSize = 10,
  }) async {
    final dtoResponse = await _remoteSource.fetchRecentDocuments(
      page: page,
      pageSize: pageSize,
    );

    return dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [];
  }
}
