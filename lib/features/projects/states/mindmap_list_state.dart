import 'package:AIPrimary/features/projects/domain/entity/mindmap_minimal.dart';

class MindmapListState {
  const MindmapListState(
    this.value,
    this.isFetched,
    this.isLoading,
    this.error,
  );

  final List<MindmapMinimal> value;
  final bool isFetched;
  final bool isLoading;
  final Object? error;

  MindmapListState copyWith(
    List<MindmapMinimal>? value,
    bool? isFetched,
    bool? isLoading,
    Object? error,
  ) {
    return MindmapListState(
      value ?? this.value,
      isFetched ?? this.isFetched,
      isLoading ?? this.isLoading,
      error ?? this.error,
    );
  }
}
