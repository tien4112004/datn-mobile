import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:AIPrimary/shared/widgets/skeleton_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Material 3 preview card for assignment resources
/// Displays assignment metadata with subject-specific color coding
/// Fetches assignment details by postId and navigates to assignment doing page
class AssignmentPreviewCard extends ConsumerWidget {
  final String postId;

  const AssignmentPreviewCard({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentAsync = ref.watch(assignmentPostProvider(postId));

    return assignmentAsync.when(
      data: (assignment) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final t = ref.watch(translationsPod);

        final subject = assignment.subject;
        final subjectColor = _getSubjectColor(subject);
        final subjectIcon = _getSubjectIcon(subject);

        return InkWell(
          onTap: () =>
              _navigateToAssignment(context, ref, assignment.assignmentId),
          borderRadius: BorderRadius.circular(12),
          child: _buildCard(
            context,
            theme,
            colorScheme,
            assignment.title,
            assignment.totalQuestions,
            assignment.totalPoints,
            subjectColor,
            subjectIcon,
          ),
        );
      },
      loading: () => const SkeletonCard(badgeCount: 2, showSubtitle: false),
      error: (error, stack) => _buildErrorCard(context),
    );
  }

  void _navigateToAssignment(
    BuildContext context,
    WidgetRef ref,
    String assignmentId,
  ) {
    // Check user role
    final user = ref.read(userControllerPod).value;

    if (user == null) return;

    // Teachers go to detail page to edit/view assignment
    if (user.role == UserRole.teacher) {
      context.router.push(AssignmentDetailRoute(assignmentId: assignmentId));
    } else {
      // Students go to preview page to take assignment
      context.router.push(
        AssignmentPreviewRoute(assignmentId: assignmentId, postId: postId),
      );
    }
  }

  Widget _buildCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    int totalQuestions,
    int totalPoints,
    Color subjectColor,
    IconData subjectIcon,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72), // Tap-friendly
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Subtle gradient background for visual interest
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            subjectColor.withValues(alpha: 0.08),
            subjectColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: subjectColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Subject Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: subjectColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              // Subtle shadow for depth
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

          const SizedBox(width: 12),

          // Content Column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
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

                // Metadata Row
                Row(
                  children: [
                    // Question Count
                    _buildMetadataBadge(
                      context,
                      label: '$totalQuestions Q',
                      color: colorScheme.tertiary,
                    ),

                    const SizedBox(width: 8),

                    // Total Points
                    _buildMetadataBadge(
                      context,
                      label: '$totalPoints pts',
                      color: const Color(0xFFF97316), // Orange CTA
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Arrow Icon
          Icon(
            LucideIcons.arrowRight,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load assignment',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get subject color for visual distinction
  Color _getSubjectColor(Subject subject) {
    switch (subject) {
      case Subject.english:
        return Themes.primaryColor; // Primary - Communication
      case Subject.mathematics:
        return const Color(0xFFDC2626); // Red - Logic
      case Subject.literature:
        return const Color(0xFF16A34A); // Green - Creativity
    }
  }

  /// Get subject icon
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

  /// Build metadata badge with icon and label
  Widget _buildMetadataBadge(
    BuildContext context, {
    required String label,
    required Color color,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPrimary ? 10 : 8,
        vertical: isPrimary ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isPrimary ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: isPrimary
            ? Border.all(color: color.withValues(alpha: 0.4), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
