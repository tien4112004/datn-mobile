part of 'repository_provider.dart';

class MindmapRepositoryImpl implements MindmapRepository {
  final ProjectsRemoteSource _remoteSource;

  MindmapRepositoryImpl(this._remoteSource);

  @override
  Future<List<MindmapMinimal>> fetchMindmaps() async {
    final dtoResponse = await _remoteSource.fetchMindmaps();
    return dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [];
  }

  @override
  Future<Mindmap> fetchMindmapById(String id) async {
    final httpResponse = await _remoteSource.fetchMindmapById(id);

    if (httpResponse.data.data == null) {
      throw Exception('Mindmap not found');
    }

    final entity = httpResponse.data.data!.toEntity();
    entity.permissions = _parsePermissions(
      httpResponse.response.headers.value('permission'),
    );
    return entity;
  }

  List<String> _parsePermissions(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',').map((p) => p.trim()).toList();
  }

  @override
  Future<List<MindmapMinimal>> fetchMindmapMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String sort = "desc",
    String? search,
  }) async {
    final dtoResponse = await _remoteSource.fetchMindmapMinimalsPaged(
      pageKey: pageKey,
      pageSize: pageSize,
      sort: sort,
      search: search,
    );

    return dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [];
  }

  @override
  Future<void> deleteMindmap(String id) {
    return _remoteSource.deleteMindmap(id);
  }
}
