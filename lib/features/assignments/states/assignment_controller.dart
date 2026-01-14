part of 'controller_provider.dart';

/// Controller for managing the assignment list state.
class AssignmentsController extends AsyncNotifier<List<AssignmentEntity>> {
  AssignmentStatus? _statusFilter;
  String? _topicFilter;
  GradeLevel? _gradeLevelFilter;

  @override
  Future<List<AssignmentEntity>> build() async {
    return _fetchAssignments();
  }

  Future<List<AssignmentEntity>> _fetchAssignments() async {
    final repository = ref.read(assignmentRepositoryProvider);
    return repository.getAssignments(
      status: _statusFilter,
      topic: _topicFilter,
      gradeLevel: _gradeLevelFilter,
    );
  }

  /// Refreshes the assignment list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAssignments);
  }

  /// Filters assignments by status.
  Future<void> filterByStatus(AssignmentStatus? status) async {
    _statusFilter = status;
    await refresh();
  }

  /// Filters assignments by topic.
  Future<void> filterByTopic(String? topic) async {
    _topicFilter = topic;
    await refresh();
  }

  /// Filters assignments by grade level.
  Future<void> filterByGradeLevel(GradeLevel? gradeLevel) async {
    _gradeLevelFilter = gradeLevel;
    await refresh();
  }

  /// Clears all filters.
  Future<void> clearFilters() async {
    _statusFilter = null;
    _topicFilter = null;
    _gradeLevelFilter = null;
    await refresh();
  }
}

/// Controller for managing a single assignment detail.
class DetailAssignmentController extends AsyncNotifier<AssignmentEntity> {
  final String assignmentId;

  DetailAssignmentController({required this.assignmentId});

  @override
  Future<AssignmentEntity> build() async {
    return _fetchAssignment(assignmentId);
  }

  Future<AssignmentEntity> _fetchAssignment(String assignmentId) async {
    final repository = ref.read(assignmentRepositoryProvider);
    return repository.getAssignmentById(assignmentId);
  }

  /// Refreshes the assignment details.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAssignment(assignmentId));
  }
}

/// Controller for creating a new Assignment.
class CreateAssignmentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Creates a new assignment and refreshes the list.
  Future<void> createAssignment({
    required String title,
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int? timeLimitMinutes,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.createAssignment(
        title: title,
        description: description,
        topic: topic,
        gradeLevel: gradeLevel,
        difficulty: difficulty,
        timeLimitMinutes: timeLimitMinutes,
      );
      // Refresh the assignments list
      ref.invalidate(assignmentsControllerProvider);
    });
  }
}

/// Controller for updating an assignment.
class UpdateAssignmentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Updates an assignment and refreshes the list.
  Future<void> updateAssignment({
    required String assignmentId,
    String? title,
    String? description,
    int? timeLimitMinutes,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.updateAssignment(
        assignmentId: assignmentId,
        title: title,
        description: description,
        timeLimitMinutes: timeLimitMinutes,
      );
      // Refresh the assignments list and detail
      ref.invalidate(assignmentsControllerProvider);
      ref.invalidate(detailAssignmentControllerProvider(assignmentId));
    });
  }
}

/// Controller for deleting an assignment.
class DeleteAssignmentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Deletes an assignment and refreshes the list.
  Future<void> deleteAssignment(String assignmentId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.deleteAssignment(assignmentId);
      // Refresh the assignments list
      ref.invalidate(assignmentsControllerProvider);
    });
  }
}

/// Controller for archiving an assignment.
class ArchiveAssignmentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Archives an assignment and refreshes the list.
  Future<void> archiveAssignment(String assignmentId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.archiveAssignment(assignmentId);
      // Refresh the assignments list and detail
      ref.invalidate(assignmentsControllerProvider);
      ref.invalidate(detailAssignmentControllerProvider(assignmentId));
    });
  }
}

/// Controller for duplicating an assignment.
class DuplicateAssignmentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Duplicates an assignment and refreshes the list.
  Future<void> duplicateAssignment(String assignmentId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.duplicateAssignment(assignmentId);
      // Refresh the assignments list
      ref.invalidate(assignmentsControllerProvider);
    });
  }
}

/// Controller for generating assignment matrix.
class GenerateMatrixController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Generates assignment matrix using AI.
  Stream<List<MatrixItemEntity>> generateMatrix({
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    String? content,
    required int totalQuestions,
    required int totalPoints,
    List<QuestionType>? questionTypes,
  }) {
    final repository = ref.read(assignmentRepositoryProvider);
    return repository.generateMatrix(
      topic: topic,
      gradeLevel: gradeLevel,
      difficulty: difficulty,
      content: content,
      totalQuestions: totalQuestions,
      totalPoints: totalPoints,
      questionTypes: questionTypes,
    );
  }
}

/// Controller for generating questions.
class GenerateQuestionsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Generates questions based on approved matrix.
  Stream<GenerationProgress> generateQuestions({
    required String assignmentId,
    required List<MatrixItemEntity> matrix,
  }) {
    final repository = ref.read(assignmentRepositoryProvider);
    return repository.generateQuestions(
      assignmentId: assignmentId,
      matrix: matrix,
    );
  }
}
