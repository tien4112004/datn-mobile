import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/assignment_card.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/assignment_form_dialog.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/assignment_header.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/assignment_loading.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
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
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignmentsAsync = ref.watch(assignmentsControllerProvider);
    final t = ref.watch(translationsPod);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [_buildSliverAppBar(context, colorScheme, theme, t)];
        },
        body: assignmentsAsync.easyWhen(
          data: (result) {
            final assignments = result.assignments;

            if (assignments.isEmpty) {
              return EnhancedEmptyState(
                icon: LucideIcons.fileText,
                title: t.assignments.emptyState.noAssignments,
                message: t.assignments.emptyState.createFirstMessage,
                actionLabel: t.assignments.createExam,
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
          loadingWidget: () => const AssignmentLoading(),
          onRetry: () {
            ref.read(assignmentsControllerProvider.notifier).refresh();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateExamDialog(context),
        icon: const Icon(LucideIcons.plus),
        label: Text(t.assignments.createExam),
        elevation: 2,
      ),
    );
  }

  /// Builds a Material 3 sliver app bar with floating behavior
  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
    dynamic t,
  ) {
    final filterState = ref.watch(assignmentFilterProvider);

    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: filterState.hasActiveFilters ? 220 : 180,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      title: Text(
        t.assignments.title,
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
          tooltip: t.assignments.refresh,
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
