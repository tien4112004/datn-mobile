import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/students/states/controller_provider.dart';
import 'package:AIPrimary/features/students/ui/widgets/student_tile.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:AIPrimary/shared/widgets/enhanced_count_header.dart';
import 'package:AIPrimary/shared/widgets/animated_list_item.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
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
    final t = ref.watch(translationsPod);
    final studentsState = ref.watch(studentsControllerProvider(classId));

    return Scaffold(
      appBar: CustomAppBar(title: t.students.list.appBarTitle),
      body: studentsState.easyWhen(
        data: (listState) => _StudentListContent(
          classId: classId,
          students: listState.value,
          onRefresh: () =>
              ref.read(studentsControllerProvider(classId).notifier).refresh(),
        ),
      ),
      floatingActionButton: Semantics(
        label: t.classes.students.addStudent,
        button: true,
        hint: t.classes.students.addHint,
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.router.push(StudentCreateRoute(classId: classId));
          },
          icon: const Icon(LucideIcons.userPlus),
          label: Text(t.classes.students.addFirstStudent),
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
    final t = ref.watch(translationsPod);
    if (students.isEmpty) {
      return EnhancedEmptyState(
        icon: LucideIcons.users,
        title: t.students.list.emptyTitle,
        message: t.students.list.emptyMessage,
        actionLabel: t.classes.students.addFirstStudent,
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
          title: t.students.list.rosterTitle,
          count: students.length,
          countLabel: t.classes.students.student,
        ),
        // Student list with animations
        Expanded(
          child: Semantics(
            label: t.classes.students.studentCount(count: students.length),
            child: RefreshIndicator(
              onRefresh: onRefresh,
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
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic student) {
    final t = ref.read(translationsPod);
    showDialog(
      context: context,
      builder: (dialogContext) => Semantics(
        label: t.classes.students.removeSemanticLabel(
          studentName: student.fullName,
        ),
        child: AlertDialog(
          title: Text(t.classes.students.removeTitle),
          content: Text(
            t.classes.students.removeMessage(studentName: student.fullName),
            semanticsLabel: t.classes.students.removeSemanticLabel(
              studentName: student.fullName,
            ),
          ),
          actions: [
            Semantics(
              label: t.classes.actions.cancel,
              button: true,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(t.classes.actions.cancel),
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
      ),
    );
  }
}
