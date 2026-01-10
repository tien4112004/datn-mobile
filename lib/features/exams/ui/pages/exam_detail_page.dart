import 'package:datn_mobile/features/exams/states/controller_provider.dart';
import 'package:datn_mobile/features/exams/ui/widgets/exam_form_dialog.dart';
import 'package:datn_mobile/features/exams/ui/widgets/status_badge.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExamDetailPage extends ConsumerWidget {
  final String examId;

  const ExamDetailPage({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final examAsync = ref.watch(detailExamControllerProvider(examId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Text(
          'Exam Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () {
              ref.read(detailExamControllerProvider(examId).notifier).refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: examAsync.when(
        data: (exam) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.3),
                      colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(status: exam.status),
                    const SizedBox(height: 16),
                    Text(
                      exam.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (exam.description != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        exam.description!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoGrid(context, exam),
                    const SizedBox(height: 32),
                    Text(
                      'Exam Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      icon: LucideIcons.bookOpen,
                      title: 'Topic',
                      value: exam.topic,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: LucideIcons.graduationCap,
                      title: 'Grade Level',
                      value: exam.gradeLevel.displayName,
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Difficulty.getDifficultyIcon(exam.difficulty),
                      title: 'Difficulty',
                      value: exam.difficulty.displayName,
                      color: Difficulty.getDifficultyColor(exam.difficulty),
                    ),
                    if (exam.timeLimitMinutes != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        context,
                        icon: LucideIcons.clock,
                        title: 'Time Limit',
                        value: '${exam.timeLimitMinutes} minutes',
                        color: colorScheme.secondary,
                      ),
                    ],
                    const SizedBox(height: 32),
                    Text(
                      'Metadata',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMetadataCard(context, exam),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Loading exam details...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.circleX, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load exam',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(detailExamControllerProvider(examId).notifier)
                      .refresh();
                },
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: examAsync.whenOrNull(
        data: (exam) => _buildBottomActions(context, ref, exam),
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, exam) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: LucideIcons.info,
            value: '${exam.totalQuestions}',
            label: 'Questions',
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: LucideIcons.award,
            value: '${exam.totalPoints}',
            label: 'Points',
            color: colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(BuildContext context, exam) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildMetadataRow(
            context,
            icon: LucideIcons.calendar,
            label: 'Created',
            value: DateFormat('MMM d, yyyy • HH:mm').format(exam.createdAt),
          ),
          if (exam.updatedAt != null) ...[
            const SizedBox(height: 12),
            _buildMetadataRow(
              context,
              icon: LucideIcons.clock,
              label: 'Last Updated',
              value: DateFormat('MMM d, yyyy • HH:mm').format(exam.updatedAt!),
            ),
          ],
          const SizedBox(height: 12),
          _buildMetadataRow(
            context,
            icon: LucideIcons.hash,
            label: 'Exam ID',
            value: exam.examId,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref, exam) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (exam.isEditable)
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showEditDialog(context, exam),
                  icon: const Icon(LucideIcons.pencil, size: 18),
                  label: const Text('Edit'),
                ),
              ),
            if (exam.isEditable) const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _duplicateExam(context, ref, exam),
                icon: const Icon(LucideIcons.copy, size: 18),
                label: const Text('Duplicate'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, exam) {
    showDialog(
      context: context,
      builder: (context) => ExamFormDialog(exam: exam),
    );
  }

  Future<void> _duplicateExam(BuildContext context, WidgetRef ref, exam) async {
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam duplicated successfully')),
        );
      }
    }
  }
}
