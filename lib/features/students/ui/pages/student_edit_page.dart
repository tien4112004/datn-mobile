import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/students/states/controller_provider.dart';
import 'package:datn_mobile/features/students/ui/widgets/student_form.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page for editing an existing student (limited fields).
@RoutePage()
class StudentEditPage extends ConsumerWidget {
  final String classId;
  final String studentId;

  const StudentEditPage({
    super.key,
    @PathParam('classId') required this.classId,
    @PathParam('studentId') required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentByIdProvider(studentId));

    // Listen to the update controller state for loading/error
    ref.listen(updateStudentControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student updated successfully')),
          );
          context.router.maybePop();
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    final isLoading = ref.watch(updateStudentControllerProvider).isLoading;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Student'),
      body: Stack(
        children: [
          studentAsync.easyWhen(
            data: (student) => StudentForm(
              classId: classId,
              initialStudent: student,
              isEditMode: true,
              onUpdateSubmit: (request) {
                ref
                    .read(updateStudentControllerProvider.notifier)
                    .updateStudent(
                      studentId: studentId,
                      classId: classId,
                      request: request,
                    );
              },
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
