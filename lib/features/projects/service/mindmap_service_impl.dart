part of 'service_provider.dart';

class MindmapServiceImpl implements MindmapService {
  final MindmapRepository _repository;

  MindmapServiceImpl(this._repository);

  @override
  Future<List<MindmapMinimal>> fetchMindmaps() {
    return _repository.fetchMindmaps();
  }

  @override
  Future<Mindmap> fetchMindmapById(String id) {
    return _repository.fetchMindmapById(id);
  }

  @override
  Future<List<MindmapMinimal>> fetchMindmapMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String sort = "desc",
  }) {
    return _repository.fetchMindmapMinimalsPaged(
      pageKey,
      pageSize: pageSize,
      sort: sort,
    );
  }
}
