part of 'service_provider.dart';

class RecentDocumentServiceImpl implements RecentDocumentService {
  final RecentDocumentRepository _repo;

  RecentDocumentServiceImpl(this._repo);

  @override
  Future<List<RecentDocument>> fetchRecentDocuments({
    int page = 1,
    int pageSize = 10,
  }) {
    return _repo.fetchRecentDocuments(page: page, pageSize: pageSize);
  }
}
