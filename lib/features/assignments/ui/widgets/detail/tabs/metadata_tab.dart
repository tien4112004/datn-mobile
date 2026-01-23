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
            // Large title header (like "Demo 123" in reference)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
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

            const SizedBox(height: 16),

            // Colorful stat cards (like in reference design)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildColorfulStatCard(
                      context,
                      icon: LucideIcons.bookOpen,
                      label: 'SUBJECT',
                      value: assignment.subject.displayName,
                      backgroundColor: const Color(0xFFDEEBFF),
                      iconColor: const Color(0xFF0052CC),
                      valueColor: const Color(0xFF0052CC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildColorfulStatCard(
                      context,
                      icon: LucideIcons.graduationCap,
                      label: 'LEVEL',
                      value: assignment.gradeLevel.displayName,
                      backgroundColor: const Color(0xFFF3E5F5),
                      iconColor: const Color(0xFF7B1FA2),
                      valueColor: const Color(0xFF7B1FA2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildColorfulStatCard(
                      context,
                      icon: LucideIcons.listChecks,
                      label: 'ITEMS',
                      value: '${assignment.totalQuestions}',
                      backgroundColor: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF2E7D32),
                      valueColor: const Color(0xFF2E7D32),
                    ),
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
                  Icon(
                    LucideIcons.fileText,
                    size: 20,
                    color: Colors.orange.shade700,
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
                  color: Colors.orange.shade700.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade700.withValues(alpha: 0.3),
                  ),
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

  Widget _buildColorfulStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color backgroundColor,
    required Color iconColor,
    required Color valueColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: valueColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
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
