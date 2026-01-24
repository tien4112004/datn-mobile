import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension to transform AsyncValue by mapping its data
extension AsyncValueTransform<T> on AsyncValue<T> {
  /// Maps the data inside AsyncValue to a new type
  /// Preserves loading and error states
  AsyncValue<R> mapData<R>(R Function(T data) transform) {
    return when(
      data: (data) => AsyncValue.data(transform(data)),
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  }
}
