part of 'controller_provider.dart';

/// Controller for fetching all submissions for a post (teacher view)
class PostSubmissionsController extends AsyncNotifier<List<SubmissionEntity>> {
  final String postId;

  PostSubmissionsController({required this.postId});

  @override
  Future<List<SubmissionEntity>> build() async {
    return _fetchSubmissions(postId);
  }

  Future<List<SubmissionEntity>> _fetchSubmissions(String postId) async {
    final repository = ref.read(submissionRepositoryProvider);
    return repository.getPostSubmissions(postId);
  }

  /// Refresh submissions list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchSubmissions(postId));
  }
}
