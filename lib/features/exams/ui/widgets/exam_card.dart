import 'package:datn_mobile/features/exams/domain/entity/exam_entity.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:datn_mobile/features/exams/states/controller_provider.dart';
import 'package:datn_mobile/features/exams/ui/pages/exam_detail_page.dart';
import 'package:datn_mobile/features/exams/ui/widgets/exam_form_dialog.dart';
import 'package:datn_mobile/features/exams/ui/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

class ExamCard extends ConsumerWidget {
  final ExamEntity exam;

  const ExamCard({super.key, required this.exam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exam.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: exam.status),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    context,
                    icon: LucideIcons.bookOpen,
                    label: exam.topic,
                    color: colorScheme.primary,
                  ),
                  _buildInfoChip(
                    context,
                    icon: LucideIcons.graduationCap,
                    label: exam.gradeLevel.displayName,
                    color: colorScheme.tertiary,
                  ),
                  _buildInfoChip(
                    context,
                    icon: _getDifficultyIcon(exam.difficulty),
                    label: exam.difficulty.displayName,
                    color: _getDifficultyColor(exam.difficulty, colorScheme),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem(
                    context,
                    icon: LucideIcons.info,
                    label: '${exam.totalQuestions} questions',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    context,
                    icon: LucideIcons.award,
                    label: '${exam.totalPoints} points',
                  ),
                  if (exam.timeLimitMinutes != null) ...[
                    const SizedBox(width: 16),
                    _buildStatItem(
                      context,
                      icon: LucideIcons.clock,
                      label: '${exam.timeLimitMinutes} min',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Created ${_formatDate(exam.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  _buildActionButtons(context, ref, colorScheme),
                ],
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
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
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (exam.isEditable)
          IconButton(
            onPressed: () => _showEditDialog(context),
            icon: const Icon(LucideIcons.pencil, size: 18),
            tooltip: 'Edit',
            visualDensity: VisualDensity.compact,
          ),
        IconButton(
          onPressed: () => _duplicateExam(context, ref),
          icon: const Icon(LucideIcons.copy, size: 18),
          tooltip: 'Duplicate',
          visualDensity: VisualDensity.compact,
        ),
        if (exam.isDeletable)
          IconButton(
            onPressed: () => _deleteExam(context, ref),
            icon: Icon(LucideIcons.trash2, size: 18, color: colorScheme.error),
            tooltip: 'Delete',
            visualDensity: VisualDensity.compact,
          )
        else
          IconButton(
            onPressed: () => _archiveExam(context, ref),
            icon: const Icon(LucideIcons.archive, size: 18),
            tooltip: 'Archive',
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  IconData _getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return LucideIcons.trendingDown;
      case Difficulty.medium:
        return LucideIcons.minus;
      case Difficulty.hard:
        return LucideIcons.trendingUp;
    }
  }

  Color _getDifficultyColor(Difficulty difficulty, ColorScheme colorScheme) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExamDetailPage(examId: exam.examId),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExamFormDialog(exam: exam),
    );
  }

  Future<void> _duplicateExam(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Exam'),
        content: Text('Create a copy of "${exam.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(duplicateExamControllerProvider.notifier)
          .duplicateExam(exam.examId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam duplicated successfully')),
        );
      }
    }
  }

  Future<void> _deleteExam(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: Text('Are you sure you want to delete "${exam.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(deleteExamControllerProvider.notifier)
          .deleteExam(exam.examId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam deleted successfully')),
        );
      }
    }
  }

  Future<void> _archiveExam(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Exam'),
        content: Text('Archive "${exam.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(archiveExamControllerProvider.notifier)
          .archiveExam(exam.examId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam archived successfully')),
        );
      }
    }
  }
}
