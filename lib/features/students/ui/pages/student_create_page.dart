import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/students/states/controller_provider.dart';
import 'package:datn_mobile/features/students/ui/widgets/student_form.dart';
import 'package:datn_mobile/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page for creating a new student.
@RoutePage()
class StudentCreatePage extends ConsumerWidget {
  final String classId;

  const StudentCreatePage({
    super.key,
    @PathParam('classId') required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(createStudentControllerProvider).isLoading;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Student'),
      body: Stack(
        children: [
          StudentForm(
            classId: classId,
            onCreateSubmit: (request) async {
              try {
                await ref
                    .read(createStudentControllerProvider.notifier)
                    .create(classId: classId, request: request);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${request.fullName} removed successfully'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );

                  ref
                      .read(studentsControllerProvider(classId).notifier)
                      .refresh();

                  context.router.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add student: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }

              ref.listen(createStudentControllerProvider, (prev, next) {
                if (!next.isLoading && !next.hasError) {
                  context.router.pop();
                }
              });
            },
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
