part of 'controller_provider.dart';

/// Parameters for validation
class ValidationParams {
  final String assignmentId;
  final String studentId;
  final List<AnswerEntity> answers;

  const ValidationParams({
    required this.assignmentId,
    required this.studentId,
    required this.answers,
  });
}

/// Controller for validating if student can submit assignment
class ValidationController extends AsyncNotifier<ValidationResult?> {
  final ValidationParams params;

  ValidationController({required this.params});

  @override
  Future<ValidationResult?> build() async {
    // Don't auto-validate on build - wait for manual validate() call
    return null;
  }

  Future<ValidationResult?> _validate(ValidationParams params) async {
    final repository = ref.read(submissionRepositoryProvider);
    return repository.validateAttempt(
      assignmentId: params.assignmentId,
      studentId: params.studentId,
      answers: params.answers,
    );
  }

  /// Manually trigger validation
  Future<ValidationResult?> validate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _validate(params));
    return state.value;
  }

  /// Reset state
  void reset() {
    state = const AsyncData(null);
  }
}
