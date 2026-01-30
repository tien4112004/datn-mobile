import 'package:AIPrimary/features/projects/domain/entity/recent_document.dart';

abstract class RecentDocumentRepository {
  Future<List<RecentDocument>> fetchRecentDocuments({
    int page = 1,
    int pageSize = 10,
  });
}
