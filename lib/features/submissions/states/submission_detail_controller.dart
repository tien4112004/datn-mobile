part of 'controller_provider.dart';

/// Controller for fetching a single submission detail
class SubmissionDetailController extends AsyncNotifier<SubmissionEntity> {
  final String submissionId;

  SubmissionDetailController({required this.submissionId});

  @override
  Future<SubmissionEntity> build() async {
    return _fetchSubmission(submissionId);
  }

  Future<SubmissionEntity> _fetchSubmission(String submissionId) async {
    final repository = ref.read(submissionRepositoryProvider);
    return repository.getSubmissionById(submissionId);
  }

  /// Refresh submission detail
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchSubmission(submissionId));
  }
}
