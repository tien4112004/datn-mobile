part of 'controller_provider.dart';

/// Controller for managing the assignment list state with pagination.
class AssignmentsController extends AsyncNotifier<AssignmentListResult> {
  int _currentPage = 1;
  String? _searchQuery;

  @override
  Future<AssignmentListResult> build() async {
    return _fetchAssignments();
  }

  Future<AssignmentListResult> _fetchAssignments() async {
    final repository = ref.read(assignmentRepositoryProvider);
    return repository.getAssignments(
      page: _currentPage,
      size: 20,
      search: _searchQuery,
    );
  }

  /// Refreshes the assignment list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAssignments);
  }

  /// Sets the search query and refreshes
  Future<void> setSearch(String? query) async {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page on new search
    await refresh();
  }

  /// Loads the next page of assignments
  Future<void> loadNextPage() async {
    final currentState = state.value!;
    if (_currentPage < currentState.pagination.totalPages) {
      _currentPage++;
      await refresh();
    }
  }

  /// Loads a specific page
  Future<void> loadPage(int page) async {
    _currentPage = page;
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

  /// Add questions to the assignment.
  Future<void> addQuestions(List<AssignmentQuestionEntity> questions) async {
    final currentAssignment = await future;
    final updatedQuestions = [...currentAssignment.questions, ...questions];

    // Update local state optimistically
    state = AsyncData(
      currentAssignment.copyWith(
        questions: updatedQuestions,
        totalQuestions: updatedQuestions.length,
        totalPoints: updatedQuestions
            .fold<double>(0, (sum, q) => sum + q.points)
            .toInt(),
      ),
    );

    // Sync to server
    await _syncQuestionsToServer(updatedQuestions);
  }

  /// Update a specific question (points or content).
  Future<void> updateQuestion(
    int index,
    AssignmentQuestionEntity updated,
  ) async {
    final currentAssignment = await future;
    final updatedQuestions = [...currentAssignment.questions];

    if (index < 0 || index >= updatedQuestions.length) {
      throw Exception('Invalid question index');
    }

    updatedQuestions[index] = updated;

    state = AsyncData(
      currentAssignment.copyWith(
        questions: updatedQuestions,
        totalQuestions: updatedQuestions.length,
        totalPoints: updatedQuestions
            .fold<double>(0, (sum, q) => sum + q.points)
            .toInt(),
      ),
    );

    await _syncQuestionsToServer(updatedQuestions);
  }

  /// Remove a question from the assignment.
  Future<void> removeQuestion(int index) async {
    final currentAssignment = await future;
    final updatedQuestions = [...currentAssignment.questions]..removeAt(index);

    state = AsyncData(
      currentAssignment.copyWith(
        questions: updatedQuestions,
        totalQuestions: updatedQuestions.length,
        totalPoints: updatedQuestions
            .fold<double>(0, (sum, q) => sum + q.points)
            .toInt(),
      ),
    );

    await _syncQuestionsToServer(updatedQuestions);
  }

  /// Sync questions to the server.
  Future<void> _syncQuestionsToServer(
    List<AssignmentQuestionEntity> questions,
  ) async {
    final repository = ref.read(assignmentRepositoryProvider);

    final request = AssignmentUpdateRequest(
      questions: questions.map((q) => q.toRequest()).toList(),
    );

    await repository.updateAssignment(assignmentId, request);
  }
}

/// Controller for creating a new Assignment.
class CreateAssignmentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Creates a new assignment and refreshes the list.
  Future<void> createAssignment(AssignmentCreateRequest request) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.createAssignment(request);
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
  Future<void> updateAssignment(
    String id,
    AssignmentUpdateRequest request,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(assignmentRepositoryProvider);
      await repository.updateAssignment(id, request);
      // Refresh the assignments list and detail
      ref.invalidate(assignmentsControllerProvider);
      ref.invalidate(detailAssignmentControllerProvider(id));
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
