import 'package:datn_mobile/features/projects/domain/entity/recent_document.dart';

abstract interface class RecentDocumentService {
  Future<List<RecentDocument>> fetchRecentDocuments({
    int page = 1,
    int pageSize = 10,
  });
}
