import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension providing utilities for AsyncValue to standardize
/// loading state detection across the app.
///
/// Eliminates the repeated pattern:
/// ```dart
/// final isLoading = generateState.maybeWhen(
///   data: (state) => state.isLoading,
///   loading: () => true,
///   orElse: () => false,
/// );
/// ```
extension AsyncValueUtils<T> on AsyncValue<T> {
  /// Check if the AsyncValue is in a loading state OR if the wrapped data
  /// is a state object that implements LoadingAware and reports as loading
  bool get isLoadingOrRefreshing => maybeWhen(
    loading: () => true,
    data: (state) => state is LoadingAware ? state.isLoading : false,
    orElse: () => false,
  );

  /// Check if the AsyncValue is in an error state
  bool get isInErrorState =>
      maybeWhen(error: (_, _) => true, orElse: () => false);

  /// Check if the AsyncValue has data (not loading, not error)
  bool get hasData => maybeWhen(data: (_) => true, orElse: () => false);

  /// Safely get the data value, or null if not available
  T? get dataOrNull => maybeWhen(data: (state) => state, orElse: () => null);

  /// Get error message as string, or null if not in error state
  String? get errorMessage =>
      maybeWhen(error: (error, _) => error.toString(), orElse: () => null);
}

/// Mixin for state classes that have an internal loading state
/// (e.g., during async operations while data is already loaded)
mixin LoadingAware {
  bool get isLoading;
}

/// Extension to safely handle async operations with AsyncValue
extension AsyncValueGuard on Ref {
  /// Wrap an async operation with proper error handling
  /// Returns an AsyncValue with the result or error
  Future<AsyncValue<T>> guardAsync<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return AsyncValue.data(result);
    } catch (error, stackTrace) {
      return AsyncValue.error(error, stackTrace);
    }
  }
}
