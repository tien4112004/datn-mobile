import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced empty state widget with animations and customization.
///
/// Provides a reusable, accessible empty state component with:
/// - Animated entrance with elastic bounce
/// - Pulsing circle layers for visual depth
/// - Customizable icon, title, message, and action
/// - Theme-aware colors and dark mode support
/// - Accessibility labels for screen readers
///
/// Usage:
/// ```dart
/// EnhancedEmptyState(
///   icon: LucideIcons.users,
///   title: 'No Students Yet',
///   message: 'Add students to this class to get started',
///   actionLabel: 'Add First Student',
///   onAction: () => context.router.push(StudentCreateRoute()),
/// )
/// ```
class EnhancedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? semanticLabel;
  final Widget? customIllustration;

  const EnhancedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveSemanticLabel =
        semanticLabel ??
        '$message. ${actionLabel != null ? "Tap to $actionLabel" : ""}';

    return Semantics(
      label: effectiveSemanticLabel,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated illustration
              customIllustration ??
                  _buildDefaultIllustration(context, colorScheme),
              const SizedBox(height: 32),

              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // Action button
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 32),
                Semantics(
                  label: actionLabel,
                  button: true,
                  hint: 'Double tap to $actionLabel',
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onAction?.call();
                    },
                    icon: Icon(icon),
                    label: Text(actionLabel!),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
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

  Widget _buildDefaultIllustration(
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
              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
          // Middle pulse circle
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
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
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 48, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
