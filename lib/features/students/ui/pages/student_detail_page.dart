import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/students/states/controller_provider.dart';
import 'package:datn_mobile/features/students/ui/widgets/student_info_section.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page displaying detailed information about a student.
@RoutePage()
class StudentDetailPage extends ConsumerWidget {
  final String studentId;

  const StudentDetailPage({
    super.key,
    @PathParam('studentId') required this.studentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentByIdProvider(studentId));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Student Details'),
      body: studentAsync.easyWhen(
        data: (student) =>
            SingleChildScrollView(child: StudentInfoSection(student: student)),
      ),
    );
  }
}
