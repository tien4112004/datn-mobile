import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:datn_mobile/features/exams/states/controller_provider.dart';
import 'package:datn_mobile/features/exams/ui/widgets/exam_card.dart';
import 'package:datn_mobile/features/exams/ui/widgets/exam_filters_bar.dart';
import 'package:datn_mobile/features/exams/ui/widgets/exam_form_dialog.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:datn_mobile/shared/widget/enhanced_error_state.dart';
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
                  return EnhancedEmptyState(
                    icon: LucideIcons.fileText,
                    title: 'No exams yet',
                    message: 'Create your first exam to get started',
                    actionLabel: 'Create Exam',
                    onAction: () => _showCreateExamDialog(context),
                  );
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
              error: (error, stack) => EnhancedErrorState(
                icon: LucideIcons.circleX,
                title: 'Failed to load exams',
                message: error.toString(),
                actionLabel: 'Retry',
                onRetry: () {
                  ref.read(examsControllerProvider.notifier).refresh();
                },
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

  void _showCreateExamDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const ExamFormDialog());
  }
}
