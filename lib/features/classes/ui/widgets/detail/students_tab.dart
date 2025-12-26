import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/students/states/controller_provider.dart';
import 'package:datn_mobile/features/students/ui/widgets/student_tile.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
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
        data: (listState) => _StudentsContent(
          classId: classId,
          students: listState.value,
          onRefresh: () =>
              ref.read(studentsControllerProvider(classId).notifier).refresh(),
        ),
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
  final Future<void> Function() onRefresh;

  const _StudentsContent({
    required this.classId,
    required this.students,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (students.isEmpty) {
      return _StudentsEmptyState(
        onAddStudent: () {
          context.router.push(StudentCreateRoute(classId: classId));
        },
      );
    }

    return Column(
      children: [
        // Student count header
        _StudentCountHeader(studentCount: students.length),
        // Student list
        Expanded(
          child: Semantics(
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
                  );
                },
              ),
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

/// Header showing student count with attractive design.
class _StudentCountHeader extends StatelessWidget {
  final int studentCount;

  const _StudentCountHeader({required this.studentCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.users,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class Roster',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$studentCount ${studentCount == 1 ? 'Student' : 'Students'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$studentCount',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state for the Students tab.
class _StudentsEmptyState extends StatelessWidget {
  final VoidCallback onAddStudent;

  const _StudentsEmptyState({required this.onAddStudent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label:
          'No students in this class yet. Add your first student to get started.',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon with multiple circles
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse circle
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Middle pulse circle
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.4,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Main icon container
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.secondaryContainer,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.userPlus,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'No Students Yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                'Start building your class roster.\nAdd students to begin tracking their progress.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Add student button
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
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
