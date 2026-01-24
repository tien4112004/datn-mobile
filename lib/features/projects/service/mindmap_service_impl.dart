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
    int pageKey,
    int pageSize, {
    String? search,
    SortOption? sort,
  }) {
    // Convert SortOption to API sort string
    String sortOrder = 'desc';

    if (sort != null) {
      switch (sort) {
        case SortOption.dateCreatedAsc:
          sortOrder = 'asc';
          break;
        case SortOption.dateCreatedDesc:
          sortOrder = 'desc';
          break;
        case SortOption.nameAsc:
          sortOrder = 'asc';
          break;
        case SortOption.nameDesc:
          sortOrder = 'desc';
          break;
      }
    }

    return _repository.fetchMindmapMinimalsPaged(
      pageKey,
      pageSize: 10,
      sort: sortOrder,
      search: search,
    );
  }
}
