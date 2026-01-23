import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/assignments/states/controller_provider.dart';
import 'package:datn_mobile/features/assignments/ui/widgets/assignment_card.dart';
import 'package:datn_mobile/features/assignments/ui/widgets/assignment_form_dialog.dart';
import 'package:datn_mobile/features/assignments/ui/widgets/assignment_header.dart';
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignmentsAsync = ref.watch(assignmentsControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [_buildSliverAppBar(context, colorScheme, theme)];
        },
        body: assignmentsAsync.when(
          data: (result) {
            final assignments = result.assignments;

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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateExamDialog(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Create Exam'),
        elevation: 2,
      ),
    );
  }

  /// Builds a Material 3 sliver app bar with floating behavior
  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 100,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      title: Text(
        'Assignment Management',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw),
          onPressed: () {
            ref.read(assignmentsControllerProvider.notifier).refresh();
          },
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(bottom: 16),
        background: AssignmentHeader(),
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
