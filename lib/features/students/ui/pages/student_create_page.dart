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
    // Listen to the create controller state for loading/error
    ref.listen(createStudentControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student created successfully')),
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

    final isLoading = ref.watch(createStudentControllerProvider).isLoading;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Student'),
      body: Stack(
        children: [
          StudentForm(
            classId: classId,
            onCreateSubmit: (request) {
              ref
                  .read(createStudentControllerProvider.notifier)
                  .create(classId: classId, request: request);
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
