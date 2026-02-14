import 'package:AIPrimary/features/home/providers/analytics_providers.dart';
import 'package:AIPrimary/features/students/ui/widgets/student_performance_section.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/students/states/controller_provider.dart';
import 'package:AIPrimary/features/students/ui/widgets/student_info_section.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
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
    final t = ref.watch(translationsPod);
    final studentAsync = ref.watch(studentByIdProvider(studentId));

    return Scaffold(
      appBar: CustomAppBar(title: t.students.detail.appBarTitle),
      body: studentAsync.easyWhen(
        data: (student) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudentInfoSection(student: student),
              const SizedBox(height: 16),
              ref
                  .watch(studentPerformanceByIdProvider(student.userId))
                  .easyWhen(
                    data: (performance) =>
                        StudentPerformanceSection(performance: performance),
                    loadingWidget: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (error, stack) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load performance data',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
