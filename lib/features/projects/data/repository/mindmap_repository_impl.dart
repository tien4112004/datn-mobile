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
    final dtoResponse = await _remoteSource.fetchMindmapById(id);

    if (dtoResponse.data == null) {
      throw Exception('Mindmap not found');
    }

    return dtoResponse.data!.toEntity();
  }

  @override
  Future<List<MindmapMinimal>> fetchMindmapMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String sort = "desc",
  }) async {
    final dtoResponse = await _remoteSource.fetchMindmapMinimalsPaged(
      pageKey: pageKey,
      pageSize: pageSize,
      sort: sort,
    );

    return dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [];
  }
}
