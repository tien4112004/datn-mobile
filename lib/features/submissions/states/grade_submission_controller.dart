part of 'controller_provider.dart';

/// Controller for grading a submission
class GradeSubmissionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial state needed
  }

  /// Grade a submission
  /// Updates question scores, feedback, and overall feedback
  Future<void> gradeSubmission({
    required String submissionId,
    required Map<String, double> questionScores,
    Map<String, String>? questionFeedback,
    String? overallFeedback,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(submissionRepositoryProvider);
      await repository.gradeSubmission(
        submissionId: submissionId,
        questionScores: questionScores,
        questionFeedback: questionFeedback,
        overallFeedback: overallFeedback,
      );

      // Invalidate submission detail to refresh
      ref.invalidate(submissionDetailProvider(submissionId));

      // Also invalidate post submissions list if needed
      // Note: We can't easily get postId here, so teacher will need to manually refresh
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  /// Reset state
  void reset() {
    state = const AsyncData(null);
  }
}
