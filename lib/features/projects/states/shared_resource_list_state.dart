import 'package:datn_mobile/features/projects/domain/entity/shared_resource.dart';

class SharedResourceListState {
  const SharedResourceListState(
    this.value,
    this.isFetched,
    this.isLoading,
    this.error,
  );

  final List<SharedResource> value;
  final bool isFetched;
  final bool isLoading;
  final Object? error;

  SharedResourceListState copyWith({
    List<SharedResource>? value,
    bool? isFetched,
    bool? isLoading,
    Object? error,
  }) {
    return SharedResourceListState(
      value ?? this.value,
      isFetched ?? this.isFetched,
      isLoading ?? this.isLoading,
      error ?? this.error,
    );
  }
}
