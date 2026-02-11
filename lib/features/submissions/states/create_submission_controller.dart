part of 'controller_provider.dart';

/// Controller for creating a new submission
class CreateSubmissionController extends AsyncNotifier<SubmissionEntity?> {
  @override
  Future<SubmissionEntity?> build() async {
    return null; // Initial state is null
  }

  /// Submit assignment answers
  /// Returns the created submission with auto-graded results
  Future<SubmissionEntity> submitAssignment({
    required String postId,
    required String studentId,
    required List<AnswerEntity> answers,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(submissionRepositoryProvider);
      final submission = await repository.createSubmission(
        postId: postId,
        studentId: studentId,
        answers: answers,
      );

      // Invalidate student submissions to refresh the list
      final userId = ref.read(userControllerPod).value?.id;
      if (userId != null) {
        ref.invalidate(
          studentSubmissionsProvider(
            StudentSubmissionsParams(
              assignmentId: submission.assignmentId,
              studentId: userId,
            ),
          ),
        );
      }

      return submission;
    });

    // Return the submission or throw error
    return state.value ??
        (throw state.error ?? Exception('Failed to create submission'));
  }

  /// Reset state to null
  void reset() {
    state = const AsyncData(null);
  }
}
