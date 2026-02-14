import 'package:AIPrimary/features/projects/data/repository/repository_provider.dart';
import 'package:AIPrimary/features/projects/domain/entity/recent_document.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for fetching recent documents for the dashboard
final recentDocumentsProvider =
    FutureProvider.autoDispose<List<RecentDocument>>((ref) async {
      final repository = ref.watch(recentDocumentRepositoryProvider);
      return repository.fetchRecentDocuments(page: 1, pageSize: 10);
    });
