import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';

class PresentationListState {
  const PresentationListState(
    this.value,
    this.isFetched,
    this.isLoading,
    this.error,
  );

  final List<PresentationMinimal> value;
  final bool isFetched;
  final bool isLoading;
  final Object? error;

  PresentationListState copyWith(
    List<PresentationMinimal>? value,
    bool? isFetched,
    bool? isLoading,
    Object? error,
  ) {
    return PresentationListState(
      value ?? this.value,
      isFetched ?? this.isFetched,
      isLoading ?? this.isLoading,
      error ?? this.error,
    );
  }
}
