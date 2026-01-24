import 'package:datn_mobile/features/projects/domain/entity/recent_document.dart';

class RecentDocumentListState {
  const RecentDocumentListState(
    this.value,
    this.isFetched,
    this.isLoading,
    this.error,
  );

  final List<RecentDocument> value;
  final bool isFetched;
  final bool isLoading;
  final Object? error;

  RecentDocumentListState copyWith(
    List<RecentDocument>? value,
    bool? isFetched,
    bool? isLoading,
    Object? error,
  ) {
    return RecentDocumentListState(
      value ?? this.value,
      isFetched ?? this.isFetched,
      isLoading ?? this.isLoading,
      error ?? this.error,
    );
  }
}
