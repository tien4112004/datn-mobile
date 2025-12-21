import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/shared/pods/loading_overlay_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/easy_when/easy_when_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefaultLoadingWidget extends ConsumerWidget {
  final LoadingConfig config;

  const DefaultLoadingWidget({required this.config, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // Handle overlay mode - set global loading state
    if (config.style == LoadingStyle.overlay) {
      ref.read(loadingOverlayPod.notifier).state = true;
      return const SizedBox.shrink();
    }

    // Determine the color to use
    final color = config.color ?? cs.primary;
    final size = config.size ?? 48.0;

    // Build the loading indicator based on style
    final indicator = config.style == LoadingStyle.circular
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(color),
            strokeWidth: 4.0,
          )
        : SizedBox(
            height: 4.0,
            child: LinearProgressIndicator(
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          );

    // Build widget with message if provided
    final hasMessage = config.message != null;
    final messageText = config.message ?? '';

    return Center(
      child: Padding(
        padding: config.padding,
        child: config.style == LoadingStyle.circular && hasMessage
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: size, height: size, child: indicator),
                  const SizedBox(height: 16),
                  Text(
                    messageText,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (config.style == LoadingStyle.circular)
                    SizedBox(width: size, height: size, child: indicator)
                  else
                    indicator,
                  if (hasMessage) ...[
                    const SizedBox(height: 12),
                    Text(
                      messageText,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
