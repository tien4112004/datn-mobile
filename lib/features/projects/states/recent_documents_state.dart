part of 'recent_documents_provider.dart';

/// State class for Recent Documents feature.
class RecentDocumentsState {
  final List<RecentDocument> documents;
  final bool isLoadingMore;
  final String? error;

  const RecentDocumentsState({
    this.documents = const [],
    this.isLoadingMore = false,
    this.error,
  });

  RecentDocumentsState copyWith({
    List<RecentDocument>? documents,
    bool? isLoadingMore,
    String? error,
  }) {
    return RecentDocumentsState(
      documents: documents ?? this.documents,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}
