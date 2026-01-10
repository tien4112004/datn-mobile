import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Enhanced error state widget with animations and customization.
///
/// Provides a reusable, accessible error state component with:
/// - Animated entrance with elastic bounce
/// - Pulsing circle layers for visual depth
/// - Customizable icon, title, message, and retry action
/// - Theme-aware error colors and dark mode support
/// - Accessibility labels for screen readers
///
/// Usage:
/// ```dart
/// EnhancedErrorState(
///   title: 'Failed to load data',
///   message: error.toString(),
///   actionLabel: 'Retry',
///   onRetry: () => ref.read(controller.notifier).refresh(),
/// )
/// ```
class EnhancedErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final String? semanticLabel;

  const EnhancedErrorState({
    super.key,
    this.icon = LucideIcons.circleAlert,
    this.title = 'Something went wrong',
    required this.message,
    this.actionLabel,
    this.onRetry,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveSemanticLabel =
        semanticLabel ??
        '$title. $message. ${actionLabel != null ? "Tap to $actionLabel" : ""}';

    return Semantics(
      label: effectiveSemanticLabel,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated illustration
              _buildErrorIllustration(context, colorScheme),
              const SizedBox(height: 32),

              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Error message
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // Retry button
              if (actionLabel != null && onRetry != null) ...[
                const SizedBox(height: 32),
                Semantics(
                  label: actionLabel,
                  button: true,
                  hint: 'Double tap to $actionLabel',
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onRetry?.call();
                    },
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    label: Text(actionLabel!),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIllustration(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
          // Middle pulse circle
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          // Main icon container with gradient
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.errorContainer,
                  colorScheme.errorContainer.withValues(alpha: 0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.error.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 48, color: colorScheme.error),
          ),
        ],
      ),
    );
  }
}
