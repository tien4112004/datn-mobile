import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
import 'package:datn_mobile/features/assignments/states/controller_provider.dart';
import 'package:datn_mobile/features/assignments/ui/widgets/assignment_card.dart';
import 'package:datn_mobile/features/assignments/ui/widgets/assignment_filters_bar.dart';
import 'package:datn_mobile/features/assignments/ui/widgets/assignment_form_dialog.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:datn_mobile/shared/widget/enhanced_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class AssignmentsPage extends ConsumerStatefulWidget {
  const AssignmentsPage({super.key});

  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  AssignmentStatus? _selectedStatus;
  GradeLevel? _selectedGradeLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignmentsAsync = ref.watch(assignmentsControllerProvider);

    return Scaffold(
      appBar: CustomAppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: 'Assignment Management',
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () {
              ref.read(assignmentsControllerProvider.notifier).refresh();
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
              ref
                  .read(assignmentsControllerProvider.notifier)
                  .filterByStatus(status);
            },
            onGradeLevelChanged: (gradeLevel) {
              setState(() => _selectedGradeLevel = gradeLevel);
              ref
                  .read(assignmentsControllerProvider.notifier)
                  .filterByGradeLevel(gradeLevel);
            },
            onClearFilters: () {
              setState(() {
                _selectedStatus = null;
                _selectedGradeLevel = null;
              });
              ref.read(assignmentsControllerProvider.notifier).clearFilters();
            },
          ),
          Expanded(
            child: assignmentsAsync.when(
              data: (assignments) {
                if (assignments.isEmpty) {
                  return EnhancedEmptyState(
                    icon: LucideIcons.fileText,
                    title: 'No assignments yet',
                    message: 'Create your first assignment to get started',
                    actionLabel: 'Create Exam',
                    onAction: () => _showCreateExamDialog(context),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(assignmentsControllerProvider.notifier)
                        .refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      return AssignmentCard(
                        assignment: assignment,
                        key: ValueKey(assignment.assignmentId),
                      );
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
                      'Loading assignments...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stack) => EnhancedErrorState(
                icon: LucideIcons.circleX,
                title: 'Failed to load assignments',
                message: error.toString(),
                actionLabel: 'Retry',
                onRetry: () {
                  ref.read(assignmentsControllerProvider.notifier).refresh();
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
    showDialog(
      context: context,
      builder: (context) => const AssignmentFormDialog(),
    );
  }
}
