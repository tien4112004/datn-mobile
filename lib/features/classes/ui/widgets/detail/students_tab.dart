import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/students/states/controller_provider.dart';
import 'package:datn_mobile/features/students/ui/widgets/student_tile.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:datn_mobile/shared/widget/enhanced_count_header.dart';
import 'package:datn_mobile/shared/widget/animated_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Students tab showing all students in the class.
/// Reuses the existing students module components for consistency.
class StudentsTab extends ConsumerWidget {
  final String classId;

  const StudentsTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsState = ref.watch(studentsControllerProvider(classId));

    return Scaffold(
      body: studentsState.easyWhen(
        data: (listState) => RefreshIndicator(
          onRefresh: () =>
              ref.read(studentsControllerProvider(classId).notifier).refresh(),
          child: _StudentsContent(classId: classId, students: listState.value),
        ),
        onRetry: () =>
            ref.read(studentsControllerProvider(classId).notifier).refresh(),
      ),
      floatingActionButton: Semantics(
        label: 'Add new student',
        button: true,
        hint: 'Double tap to add a student to this class',
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.router.push(StudentCreateRoute(classId: classId));
          },
          child: const Icon(LucideIcons.userPlus),
        ),
      ),
    );
  }
}

/// Content widget for the Students tab.
class _StudentsContent extends ConsumerWidget {
  final String classId;
  final List students;

  const _StudentsContent({required this.classId, required this.students});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (students.isEmpty) {
      return EnhancedEmptyState(
        icon: LucideIcons.userPlus,
        title: 'No Students Yet',
        message:
            'Start building your class roster.\nAdd students to begin tracking their progress.',
        actionLabel: 'Add First Student',
        onAction: () {
          context.router.push(StudentCreateRoute(classId: classId));
        },
      );
    }

    return Column(
      children: [
        // Enhanced count header
        EnhancedCountHeader(
          icon: LucideIcons.users,
          title: 'Class Roster',
          count: students.length,
          countLabel: 'Student',
        ),
        // Student list with animations
        Expanded(
          child: Semantics(
            label: '${students.length} students in this class',
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return AnimatedListItem(
                  index: index,
                  child: StudentTile(
                    key: ValueKey(student.id),
                    student: student,
                    onTap: () {
                      context.router.push(
                        StudentDetailRoute(studentId: student.id),
                      );
                    },
                    onEdit: () {
                      context.router.push(
                        StudentEditRoute(
                          classId: classId,
                          studentId: student.id,
                        ),
                      );
                    },
                    onDelete: () => _showDeleteDialog(context, ref, student),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic student) {
    showDialog(
      context: context,
      builder: (dialogContext) => Semantics(
        label: 'Delete confirmation dialog',
        child: AlertDialog(
          title: const Text('Remove Student'),
          content: Text(
            'Are you sure you want to remove ${student.fullName} from this class?',
            semanticsLabel:
                'Are you sure you want to remove ${student.fullName} from this class? This action cannot be undone.',
          ),
          actions: [
            Semantics(
              label: 'Cancel deletion',
              button: true,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ),
            Semantics(
              label: 'Confirm deletion of ${student.fullName}',
              button: true,
              child: FilledButton(
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  Navigator.of(dialogContext).pop();

                  // Show loading indicator
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 16),
                            Text('Removing student...'),
                          ],
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }

                  try {
                    await ref
                        .read(removeStudentControllerProvider.notifier)
                        .remove(classId: classId, studentId: student.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${student.fullName} removed successfully',
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      );

                      ref
                          .read(studentsControllerProvider(classId).notifier)
                          .refresh();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to remove student: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Remove'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
