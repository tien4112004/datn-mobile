import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/easy_when/easy_when_config.dart';
import 'package:datn_mobile/shared/riverpod_ext/easy_when/widgets/debounced_retry_button.dart';
import 'package:datn_mobile/shared/riverpod_ext/easy_when/widgets/dio_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefaultErrorWidget extends ConsumerWidget {
  final Object error;
  final StackTrace stackTrace;
  final VoidCallback? onRetry;
  final ErrorConfig errorConfig;

  const DefaultErrorWidget({
    required this.error,
    required this.stackTrace,
    required this.onRetry,
    required this.errorConfig,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final cs = Theme.of(context).colorScheme;

    final iconColor = errorConfig.iconColor ?? cs.error;
    final textColor =
        errorConfig.textColor ??
        (context.isDarkMode ? Colors.white : Colors.grey[900]!);

    // Build error message widget
    final errorMessage = DioErrorMessage(
      error: error,
      showDioDetails: errorConfig.showDioErrorDetails,
      textColor: textColor,
    );

    // Build retry button if callback provided
    final retryButton = onRetry != null
        ? DebouncedRetryButton(
            onPressed: onRetry!,
            config: errorConfig.showDioErrorDetails
                ? const RetryConfig()
                : const RetryConfig.noDebounce(),
            defaultLabel: t.common.retry,
          )
        : null;

    // Handle minimal style (just message, no icon)
    if (errorConfig.style == ErrorStyle.minimal) {
      return Center(
        child: Padding(
          padding: errorConfig.padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              errorMessage,
              if (retryButton != null) ...[
                const SizedBox(height: 16),
                retryButton,
              ],
            ],
          ),
        ),
      );
    }

    // Handle card style (vertical layout with icon)
    if (errorConfig.style == ErrorStyle.card) {
      return Center(
        child: Padding(
          padding: errorConfig.padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon with circle
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(Icons.error_outline, color: iconColor, size: 48),
                ),
              ),
              const SizedBox(height: 16),
              // Error title
              Text(
                t.common.somethingWentWrong,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Error message
              errorMessage,
              // Stack trace in debug mode
              if (errorConfig.showStackTrace) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900]?.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stackTrace.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (retryButton != null) ...[
                const SizedBox(height: 24),
                retryButton,
              ],
            ],
          ),
        ),
      );
    }

    // Handle inline style (horizontal layout)
    return Center(
      child: Padding(
        padding: errorConfig.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [errorMessage],
              ),
            ),
            const SizedBox(width: 12),
            if (retryButton != null) retryButton,
          ],
        ),
      ),
    );
  }
}
