import 'package:datn_mobile/shared/riverpod_ext/easy_when/easy_when_config.dart';
import 'package:datn_mobile/shared/riverpod_ext/easy_when/widgets/default_loading_widget.dart';
import 'package:datn_mobile/shared/widgets/enhanced_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Modernized AsyncValue extension with support for theme-aware, i18n,
/// and debounced retry functionality
extension AsyncDisplay<T> on AsyncValue<T> {
  Widget easyWhen({
    required Widget Function(T data) data,
    Widget Function(Object error, StackTrace stackTrace)? errorWidget,
    Widget Function()? loadingWidget,
    LoadingConfig? loadingConfig,
    VoidCallback? onRetry,
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    @Deprecated('Use loadingConfig instead') bool isLinear = false,
  }) {
    // Convert deprecated parameters to new config if provided
    final finalLoadingConfig =
        loadingConfig ??
        (isLinear
            ? const LoadingConfig.linear()
            : const LoadingConfig.circular());
    return when(
      data: data,
      error: (error, stackTrace) {
        return errorWidget != null
            ? errorWidget(error, stackTrace)
            : EnhancedErrorState(
                message: error.toString(),
                actionLabel: onRetry != null ? 'Retry' : null,
                onRetry: onRetry,
                icon: LucideIcons.circleAlert,
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
