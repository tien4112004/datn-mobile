import 'package:AIPrimary/features/projects/domain/entity/recent_document.dart';
import 'package:AIPrimary/features/projects/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'recent_documents_state.dart';

/// Provider for Recent Documents state management.
final recentDocumentsProvider =
    AsyncNotifierProvider<RecentDocumentsController, RecentDocumentsState>(() {
      return RecentDocumentsController();
    });

class RecentDocumentsController extends AsyncNotifier<RecentDocumentsState> {
  @override
  RecentDocumentsState build() {
    return const RecentDocumentsState();
  }

  /// Loads recent documents
  Future<void> loadRecentDocuments() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(recentDocumentServiceProvider);

      final result = await service.fetchRecentDocuments(page: 1, pageSize: 10);

      return RecentDocumentsState(documents: result);
    });
  }
}
