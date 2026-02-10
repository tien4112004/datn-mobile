import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/assignments/ui/pages/assignment_detail_page.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/assignment_form_dialog.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/status_badge.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AssignmentCard extends ConsumerWidget {
  final AssignmentEntity assignment;

  const AssignmentCard({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // Soft outer shadow (claymorphism effect)
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          // Subtle inner highlight
          BoxShadow(
            color: colorScheme.surface.withValues(alpha: 0.9),
            offset: const Offset(0, -1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title and Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        assignment.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusBadge(status: assignment.status),
                  ],
                ),

                if (assignment.description != null &&
                    assignment.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    assignment.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 16),

                // Info Chips Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      context,
                      icon: LucideIcons.bookOpen,
                      label: assignment.subject.getLocalizedName(t),
                      color: colorScheme.primary,
                    ),
                    _buildInfoChip(
                      context,
                      icon: LucideIcons.graduationCap,
                      label: assignment.gradeLevel.getLocalizedName(t),
                      color: colorScheme.tertiary,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stats Row with enhanced visual hierarchy
                Row(
                  children: [
                    _buildStatItem(
                      context,
                      icon: LucideIcons.listChecks,
                      label: '${assignment.totalQuestions}',
                      sublabel: t.assignments.card.questions,
                    ),
                    const SizedBox(width: 20),
                    _buildStatItem(
                      context,
                      icon: LucideIcons.award,
                      label: '${assignment.totalPoints}',
                      sublabel: t.assignments.card.points,
                    ),
                    if (assignment.timeLimitMinutes != null) ...[
                      const SizedBox(width: 20),
                      _buildStatItem(
                        context,
                        icon: LucideIcons.clock,
                        label: '${assignment.timeLimitMinutes}',
                        sublabel: t.assignments.card.min,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Divider(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  height: 1,
                ),

                const SizedBox(height: 12),

                // Footer: Timestamp and Actions
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 16,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (assignment.createdAt != null) ...[
                      Text(
                        '${t.assignments.dates.createdPrefix} ${DateFormatHelper.formatRelativeDate(assignment.createdAt!, ref: ref)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    _buildActionButtons(context, ref, colorScheme, t),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sublabel,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            Text(
              sublabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (assignment.isEditable)
          IconButton(
            onPressed: () => _showEditDialog(context),
            icon: const Icon(LucideIcons.pencil, size: 18),
            tooltip: t.assignments.card.edit,
            visualDensity: VisualDensity.compact,
          ),
        // Duplicate and Archive features not supported by current API
        if (assignment.isDeletable)
          IconButton(
            onPressed: () => _deleteAssignment(context, ref, t),
            icon: Icon(LucideIcons.trash2, size: 18, color: colorScheme.error),
            tooltip: t.assignments.card.delete,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AssignmentDetailPage(assignmentId: assignment.assignmentId),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssignmentFormDialog(assignment: assignment),
    );
  }

  Future<void> _deleteAssignment(
    BuildContext context,
    WidgetRef ref,
    dynamic t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.assignments.deleteDialog.title),
        content: Text(
          t.assignments.deleteDialog.message(title: assignment.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.assignments.deleteDialog.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.assignments.deleteDialog.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(deleteAssignmentControllerProvider.notifier)
          .deleteAssignment(assignment.assignmentId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.assignments.deleteDialog.success)),
        );
      }
    }
  }
}
