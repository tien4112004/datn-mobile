import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/students/states/controller_provider.dart';
import 'package:datn_mobile/features/students/ui/widgets/student_tile.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Page displaying a list of students for a specific class.
@RoutePage()
class StudentListPage extends ConsumerWidget {
  final String classId;

  const StudentListPage({
    super.key,
    @PathParam('classId') required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsState = ref.watch(studentsControllerProvider(classId));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Students'),
      body: studentsState.easyWhen(
        data: (listState) => _StudentListContent(
          classId: classId,
          students: listState.value,
          onRefresh: () =>
              ref.read(studentsControllerProvider(classId).notifier).refresh(),
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Add new student',
        button: true,
        hint: 'Double tap to create a new student',
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.router.push(StudentCreateRoute(classId: classId));
          },
          icon: const Icon(LucideIcons.userPlus),
          label: const Text('Add Student'),
        ),
      ),
    );
  }
}

class _StudentListContent extends ConsumerWidget {
  final String classId;
  final List students;
  final Future<void> Function() onRefresh;

  const _StudentListContent({
    required this.classId,
    required this.students,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (students.isEmpty) {
      return _EmptyState(
        onAddStudent: () {
          context.router.push(StudentCreateRoute(classId: classId));
        },
      );
    }

    return Semantics(
      label: '${students.length} students in this class',
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return StudentTile(
              key: ValueKey(student.id),
              student: student,
              onTap: () {
                context.router.push(StudentDetailRoute(studentId: student.id));
              },
              onEdit: () {
                context.router.push(
                  StudentEditRoute(classId: classId, studentId: student.id),
                );
              },
              onDelete: () => _showDeleteDialog(context, ref, student),
            );
          },
        ),
      ),
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddStudent;

  const _EmptyState({required this.onAddStudent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label:
          'No students in this class yet. Add your first student to get started.',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.users,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Students Yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add students to this class to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Semantics(
                label: 'Add first student',
                button: true,
                hint: 'Double tap to add your first student to this class',
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onAddStudent();
                  },
                  icon: const Icon(LucideIcons.userPlus),
                  label: const Text('Add First Student'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
