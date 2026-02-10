import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Assignment selection section for exercise posts
class AssignmentSelectionSection extends ConsumerWidget {
  final String? assignmentId;
  final bool isDisabled;
  final VoidCallback onPickAssignment;

  const AssignmentSelectionSection({
    super.key,
    required this.assignmentId,
    required this.isDisabled,
    required this.onPickAssignment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If no assignment selected, show placeholder
    if (assignmentId == null) {
      return _buildPlaceholder(theme, colorScheme);
    }

    // Fetch assignment details
    final assignmentAsync = ref.watch(
      detailAssignmentControllerProvider(assignmentId!),
    );

    return assignmentAsync.when(
      data: (assignment) => _buildWithAssignment(
        theme,
        colorScheme,
        assignment.title,
        assignment.subject,
        assignment.gradeLevel,
        assignment.totalQuestions,
        t,
      ),
      loading: () => _buildLoading(theme, colorScheme),
      error: (error, stack) =>
          _buildPlaceholder(theme, colorScheme, hasError: true),
    );
  }

  Widget _buildPlaceholder(
    ThemeData theme,
    ColorScheme colorScheme, {
    bool hasError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: hasError
            ? colorScheme.errorContainer.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isDisabled ? null : onPickAssignment,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Assignment Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasError
                        ? colorScheme.error.withValues(alpha: 0.15)
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasError
                        ? LucideIcons.circleAlert
                        : LucideIcons.clipboardList,
                    size: 20,
                    color: hasError
                        ? colorScheme.error
                        : colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 16),

                // Assignment Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assignment',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasError ? 'Failed to load' : 'Select assignment',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: hasError
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Loading Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Loading text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assignment',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Loading...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithAssignment(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    Subject subject,
    GradeLevel gradeLevel,
    int totalQuestions,
    Translations t,
  ) {
    final subjectColor = _getSubjectColor(subject);
    final subjectIcon = _getSubjectIcon(subject);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPickAssignment,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  subjectColor.withValues(alpha: 0.08),
                  subjectColor.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: subjectColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Subject Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: subjectColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(subjectIcon, size: 24, color: subjectColor),
                ),
                const SizedBox(width: 16),

                // Assignment Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildBadge(
                            theme,
                            label: subject.getLocalizedName(t),
                            color: subjectColor,
                          ),
                          const SizedBox(width: 6),
                          _buildBadge(
                            theme,
                            label: gradeLevel.getLocalizedName(t),
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          _buildBadge(
                            theme,
                            label: '$totalQuestions Q',
                            color: colorScheme.tertiary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    ThemeData theme, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getSubjectColor(Subject subject) {
    switch (subject) {
      case Subject.english:
        return Themes.primaryColor;
      case Subject.mathematics:
        return const Color(0xFFDC2626);
      case Subject.literature:
        return const Color(0xFF16A34A);
    }
  }

  IconData _getSubjectIcon(Subject subject) {
    switch (subject) {
      case Subject.english:
        return LucideIcons.messageSquare;
      case Subject.mathematics:
        return LucideIcons.calculator;
      case Subject.literature:
        return LucideIcons.bookOpen;
    }
  }
}
