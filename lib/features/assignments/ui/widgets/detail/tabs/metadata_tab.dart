import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/ui/widgets/assignment_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Metadata tab with clean, modern design matching the Info tab reference.
/// Features: Large title, colored stat cards, instructions section.
class MetadataTab extends StatelessWidget {
  final AssignmentEntity assignment;
  final bool isEditMode;
  final ValueChanged<bool>? onShuffleChanged;

  const MetadataTab({
    super.key,
    required this.assignment,
    this.isEditMode = false,
    this.onShuffleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEEBFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.fileQuestionMark,
                      color: Color(0xFF0052CC),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Created on ${_formatDate(assignment.createdAt)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEditMode)
                    IconButton(
                      icon: const Icon(LucideIcons.pencil, size: 20),
                      onPressed: () => _showEditDialog(context),
                      tooltip: 'Edit Assignment',
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                ],
              ),
            ),

            // Assignment Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) {
                      return Divider(
                        indent: 62,
                        height: 1,
                        color: colorScheme.outlineVariant,
                      );
                    },
                    itemBuilder: (context, index) {
                      final metrics = [
                        (
                          icon: LucideIcons.bookOpen,
                          label: 'Subject',
                          value: assignment.subject.displayName,
                        ),
                        (
                          icon: LucideIcons.graduationCap,
                          label: 'Grade Level',
                          value: assignment.gradeLevel.displayName,
                        ),
                        (
                          icon: LucideIcons.listChecks,
                          label: 'Total Questions',
                          value: '${assignment.totalQuestions}',
                        ),
                      ];

                      final metric = metrics[index];
                      return _buildMetricRow(
                        context,
                        icon: metric.icon,
                        label: metric.label,
                        value: metric.value,
                        theme: theme,
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Description section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEEBFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.fileText,
                      color: Color(0xFF0052CC),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  (assignment.description == null ||
                          assignment.description!.isEmpty)
                      ? 'No Description Provided'
                      : assignment.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Shuffle toggle (only in edit mode)
            if (isEditMode) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: SwitchListTile(
                    value: assignment.shuffleQuestions,
                    onChanged: onShuffleChanged,
                    title: Text(
                      'Shuffle Questions',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Randomize question order for each student',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: assignment.shuffleQuestions
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.shuffle,
                        color: assignment.shuffleQuestions
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],

            // Bottom padding
            SizedBox(height: isEditMode ? 174.0 : 88.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssignmentFormDialog(assignment: assignment),
    );
  }
}
