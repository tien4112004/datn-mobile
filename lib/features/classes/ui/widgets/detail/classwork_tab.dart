import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Classwork tab showing documents and assignments grouped by date.
/// Currently displays an empty state as the API is not yet available.
class ClassworkTab extends StatelessWidget {
  final String classId;

  const ClassworkTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return const _ClassworkEmptyState();
  }
}

/// Empty state for the Classwork tab with attractive design.
class _ClassworkEmptyState extends StatelessWidget {
  const _ClassworkEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label:
          'No classwork yet. Assignments and materials will appear here when your teacher posts them.',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stacked documents icon with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background documents
                    Container(
                      width: 140,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.secondaryContainer,
                          ],
                        ),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(16),
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.fileText,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.secondaryContainer,
                          ],
                        ),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(16),
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.fileText,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    ),
                    // Main document
                    _DocumentIcon(
                      color: colorScheme.primaryContainer,
                      opacity: 1.0,
                      child: Icon(
                        LucideIcons.fileText,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Title with fade animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: Text(
                  'No Classwork Yet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              // Description with fade animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: Text(
                  'Assignments, quizzes, and materials\nwill be posted here by your teacher.\nOrganized by date for easy access.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Feature highlights
              _FeatureHighlight(
                icon: LucideIcons.clipboardList,
                title: 'Assignments',
                description: 'Submit your work and track deadlines',
                colorScheme: colorScheme,
                delay: 0,
              ),
              const SizedBox(height: 12),
              _FeatureHighlight(
                icon: LucideIcons.folderOpen,
                title: 'Materials',
                description: 'Access course documents and resources',
                colorScheme: colorScheme,
                delay: 100,
              ),
              const SizedBox(height: 12),
              _FeatureHighlight(
                icon: LucideIcons.clock,
                title: 'Due Dates',
                description: 'Never miss an assignment deadline',
                colorScheme: colorScheme,
                delay: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Document icon widget for the stacked documents effect.
class _DocumentIcon extends StatelessWidget {
  final Color color;
  final double opacity;
  final Widget? child;

  const _DocumentIcon({required this.color, required this.opacity, this.child});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}

/// Feature highlight card with animation.
class _FeatureHighlight extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final ColorScheme colorScheme;
  final int delay;

  const _FeatureHighlight({
    required this.icon,
    required this.title,
    required this.description,
    required this.colorScheme,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 26, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
