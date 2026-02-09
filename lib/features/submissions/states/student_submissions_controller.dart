part of 'controller_provider.dart';

/// Controller for fetching student's own submissions
class StudentSubmissionsController
    extends AsyncNotifier<List<SubmissionEntity>> {
  final StudentSubmissionsParams params;

  StudentSubmissionsController({required this.params});

  @override
  Future<List<SubmissionEntity>> build() async {
    return _fetchSubmissions(params);
  }

  Future<List<SubmissionEntity>> _fetchSubmissions(
    StudentSubmissionsParams params,
  ) async {
    final repository = ref.read(submissionRepositoryProvider);
    return repository.getStudentSubmissions(
      assignmentId: params.assignmentId,
      studentId: params.studentId,
    );
  }

  /// Refresh submissions list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchSubmissions(params));
  }
}
