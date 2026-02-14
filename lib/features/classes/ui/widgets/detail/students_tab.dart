import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/features/students/states/controller_provider.dart';
import 'package:AIPrimary/features/students/ui/widgets/student_tile.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:AIPrimary/shared/widgets/enhanced_count_header.dart';
import 'package:AIPrimary/shared/widgets/animated_list_item.dart';
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
    final t = ref.watch(translationsPod);
    final userRole = ref.watch(userRolePod);
    final isStudent = userRole == UserRole.student;

    return Scaffold(
      body: studentsState.easyWhen(
        data: (listState) => RefreshIndicator(
          onRefresh: () =>
              ref.read(studentsControllerProvider(classId).notifier).refresh(),
          child: _StudentsContent(
            classId: classId,
            students: listState.value,
            t: t,
          ),
        ),
        onRetry: () =>
            ref.read(studentsControllerProvider(classId).notifier).refresh(),
      ),
      floatingActionButton: (isStudent)
          ? null
          : Semantics(
              label: t.classes.students.addStudent,
              button: true,
              hint: t.classes.students.addHint,
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
  final dynamic t;

  const _StudentsContent({
    required this.classId,
    required this.students,
    required this.t,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (students.isEmpty) {
      return EnhancedEmptyState(
        icon: LucideIcons.userPlus,
        title: t.classes.students.emptyTitle,
        message: t.classes.students.emptyDescription,
        actionLabel: t.classes.students.addFirstStudent,
        onAction: () {
          context.router.push(StudentCreateRoute(classId: classId));
        },
      );
    }

    final isStudent = ref.watch(userRolePod) == UserRole.student;
    final currentUserId = ref.watch(userIdPod);

    // Sort students to show current student first if viewing as a student
    final sortedStudents = List.from(students);
    if (isStudent) {
      sortedStudents.sort((a, b) {
        // Current student comes first
        if (a.userId == currentUserId) return -1;
        if (b.userId == currentUserId) return 1;
        // Maintain original order for others
        return 0;
      });
    }

    return Column(
      children: [
        // Enhanced count header
        EnhancedCountHeader(
          icon: LucideIcons.users,
          title: t.classes.students.classRoster,
          count: students.length,
          countLabel: t.classes.students.student,
        ),
        // Student list with animations
        Expanded(
          child: Semantics(
            label: t.classes.students.studentCount(count: students.length),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: sortedStudents.length,
              itemBuilder: (context, index) {
                final student = sortedStudents[index];
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
                    isCurrentStudent:
                        isStudent && student.userId == ref.watch(userIdPod),
                    onEdit: isStudent
                        ? null
                        : () {
                            context.router.push(
                              StudentEditRoute(
                                classId: classId,
                                studentId: student.id,
                              ),
                            );
                          },
                    onDelete: isStudent
                        ? null
                        : () => _showDeleteDialog(context, ref, student),
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
      builder: (dialogContext) => AlertDialog(
        title: Text(t.classes.students.removeTitle),
        content: Text(
          t.classes.students.removeMessage(studentName: student.fullName),
          semanticsLabel: t.classes.students.removeSemanticLabel(
            studentName: student.fullName,
          ),
        ),
        actions: [
          Semantics(
            label: t.classes.cancel,
            button: true,
            child: TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t.classes.cancel),
            ),
          ),
          Semantics(
            label: t.classes.students.confirmRemove(
              studentName: student.fullName,
            ),
            button: true,
            child: FilledButton(
              onPressed: () async {
                HapticFeedback.heavyImpact();
                Navigator.of(dialogContext).pop();

                // Show loading indicator
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 16),
                          Text(t.classes.students.removing),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
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
                          t.classes.students.removeSuccess(
                            studentName: student.fullName,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
                        content: Text(
                          t.classes.students.removeError(error: e.toString()),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(t.classes.students.remove),
            ),
          ),
        ],
      ),
    );
  }
}
