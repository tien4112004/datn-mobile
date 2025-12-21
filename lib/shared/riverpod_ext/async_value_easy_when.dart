import 'package:datn_mobile/shared/riverpod_ext/easy_when/easy_when_config.dart';
import 'package:datn_mobile/shared/riverpod_ext/easy_when/widgets/default_error_widget.dart';
import 'package:datn_mobile/shared/riverpod_ext/easy_when/widgets/default_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modernized AsyncValue extension with support for theme-aware, i18n,
/// and debounced retry functionality
extension AsyncDisplay<T> on AsyncValue<T> {
  Widget easyWhen({
    required Widget Function(T data) data,
    Widget Function(Object error, StackTrace stackTrace)? errorWidget,
    Widget Function()? loadingWidget,
    LoadingConfig? loadingConfig,
    ErrorConfig? errorConfig,
    VoidCallback? onRetry,
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    // Deprecated parameters - kept for backwards compatibility
    @Deprecated('Use loadingConfig instead') bool isLinear = false,
    @Deprecated('Use errorConfig instead')
    bool includedefaultDioErrorMessage = false,
  }) {
    // Convert deprecated parameters to new config if provided
    final finalLoadingConfig =
        loadingConfig ??
        (isLinear
            ? const LoadingConfig.linear()
            : const LoadingConfig.circular());
    final finalErrorConfig =
        errorConfig ??
        ErrorConfig(
          showDioErrorDetails: includedefaultDioErrorMessage,
          style: isLinear ? ErrorStyle.inline : ErrorStyle.card,
        );

    return when(
      data: data,
      error: (error, stackTrace) {
        return errorWidget != null
            ? errorWidget(error, stackTrace)
            : DefaultErrorWidget(
                error: error,
                stackTrace: stackTrace,
                onRetry: onRetry,
                errorConfig: finalErrorConfig,
              );
      },
      loading: () {
        return loadingWidget != null
            ? loadingWidget()
            : DefaultLoadingWidget(config: finalLoadingConfig);
      },
      skipError: skipError,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipLoadingOnReload: skipLoadingOnReload,
    );
  }
}
