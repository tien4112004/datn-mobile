part of 'controller_provider.dart';

/// Controller for fetching submission statistics for a post
class SubmissionStatisticsController
    extends AsyncNotifier<SubmissionStatisticsEntity> {
  final String postId;

  SubmissionStatisticsController({required this.postId});

  @override
  Future<SubmissionStatisticsEntity> build() async {
    return _fetchStatistics(postId);
  }

  Future<SubmissionStatisticsEntity> _fetchStatistics(String postId) async {
    final repository = ref.read(submissionRepositoryProvider);
    return repository.getSubmissionStatistics(postId);
  }

  /// Refresh statistics data
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStatistics(postId));
  }
}
