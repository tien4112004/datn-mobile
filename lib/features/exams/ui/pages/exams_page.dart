import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:datn_mobile/features/exams/states/controller_provider.dart';
import 'package:datn_mobile/features/exams/ui/widgets/exam_card.dart';
import 'package:datn_mobile/features/exams/ui/widgets/exam_filters_bar.dart';
import 'package:datn_mobile/features/exams/ui/widgets/exam_form_dialog.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ExamsPage extends ConsumerStatefulWidget {
  const ExamsPage({super.key});

  @override
  ConsumerState<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends ConsumerState<ExamsPage> {
  ExamStatus? _selectedStatus;
  GradeLevel? _selectedGradeLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final examsAsync = ref.watch(examsControllerProvider);

    return Scaffold(
      appBar: CustomAppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: 'Exam Management',
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () {
              ref.read(examsControllerProvider.notifier).refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          ExamFiltersBar(
            selectedStatus: _selectedStatus,
            selectedGradeLevel: _selectedGradeLevel,
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
              ref.read(examsControllerProvider.notifier).filterByStatus(status);
            },
            onGradeLevelChanged: (gradeLevel) {
              setState(() => _selectedGradeLevel = gradeLevel);
              ref
                  .read(examsControllerProvider.notifier)
                  .filterByGradeLevel(gradeLevel);
            },
            onClearFilters: () {
              setState(() {
                _selectedStatus = null;
                _selectedGradeLevel = null;
              });
              ref.read(examsControllerProvider.notifier).clearFilters();
            },
          ),
          Expanded(
            child: examsAsync.when(
              data: (exams) {
                if (exams.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(examsControllerProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return ExamCard(exam: exam, key: ValueKey(exam.examId));
                    },
                  ),
                );
              },
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading exams...',
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
                    Icon(
                      LucideIcons.circleX,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load exams',
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
                        ref.read(examsControllerProvider.notifier).refresh();
                      },
                      icon: const Icon(LucideIcons.refreshCw, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateExamDialog(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Create Exam'),
        elevation: 2,
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.fileText,
              size: 64,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No exams yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first exam to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreateExamDialog(context),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Create Exam'),
          ),
        ],
      ),
    );
  }

  void _showCreateExamDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const ExamFormDialog());
  }
}
