part of 'controller_provider.dart';

/// Controller for managing the assignment list state with pagination and filtering.
class AssignmentsController extends AsyncNotifier<AssignmentListResult> {
  int _currentPage = 1;

  @override
  Future<AssignmentListResult> build() async {
    return _fetchAssignments();
  }

  Future<AssignmentListResult> _fetchAssignments() async {
    // Read filter state from provider
    final filterState = ref.read(assignmentFilterProvider);
    final filterParams = filterState.getFilterParams();

    final repository = ref.read(assignmentRepositoryProvider);
    return repository.getAssignments(
      page: _currentPage,
      size: 20,
      search: filterParams.search,
      // TODO: Pass other filter params when API supports them
      // status: filterParams.status,
      // gradeLevel: filterParams.gradeLevel,
      // subject: filterParams.subject,
      // difficulty: filterParams.difficulty,
    );
  }

  /// Refreshes the assignment list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAssignments);
  }

  /// Loads assignments with current filter state.
  /// Called after filter changes.
  Future<void> loadAssignmentsWithFilter() async {
    _currentPage = 1; // Reset to first page when filters change
    await refresh();
  }

  /// Sets the search query via filter state and refreshes
  Future<void> setSearch(String? query) async {
    final currentFilter = ref.read(assignmentFilterProvider);
    ref.read(assignmentFilterProvider.notifier).state = currentFilter.copyWith(
      searchQuery: query,
    );
    await loadAssignmentsWithFilter();
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

  /// Clears contextId from all questions that reference the given contextId.
  /// Used when a context is unlinked from the assignment.
  Future<void> clearContextIdFromQuestions(String contextId) async {
    final currentAssignment = await future;
    final updatedQuestions = currentAssignment.questions.map((q) {
      if (q.contextId == contextId) {
        return q.copyWith(clearContextId: true);
      }
      return q;
    }).toList();

    state = AsyncData(currentAssignment.copyWith(questions: updatedQuestions));
  }

  /// Update a single cell in the matrix (optimistic local update only).
  /// Server sync happens when the user presses Save.
  Future<void> updateMatrixCell(
    int subtopicIndex,
    int difficultyIndex,
    int questionTypeIndex,
    String cellValue,
  ) async {
    final currentAssignment = await future;
    if (currentAssignment.matrix == null) return;

    final newMatrix = currentAssignment.matrix!.deepCopyMatrix();
    newMatrix[subtopicIndex][difficultyIndex][questionTypeIndex] = cellValue;

    // Recalculate totals from all cells
    int totalCount = 0;
    double totalPts = 0.0;
    for (final subtopic in newMatrix) {
      for (final difficulty in subtopic) {
        for (final cell in difficulty) {
          final parsed = parseCellValue(cell);
          totalCount += parsed.count;
          totalPts += parsed.points;
        }
      }
    }

    state = AsyncData(
      currentAssignment.copyWith(
        matrix: currentAssignment.matrix!.copyWith(
          matrix: newMatrix,
          totalQuestions: totalCount,
          totalPoints: totalPts.toInt(),
        ),
      ),
    );
  }

  /// Update shuffle questions setting.
  Future<void> updateShuffleQuestions(bool shuffle) async {
    final currentAssignment = await future;

    // Update local state optimistically
    state = AsyncData(currentAssignment.copyWith(shuffleQuestions: shuffle));

    // Sync to server (use UpdateAssignmentController for proper update)
    final repository = ref.read(assignmentRepositoryProvider);
    await repository.updateAssignment(
      assignmentId,
      const AssignmentUpdateRequest(
        // Note: API might not support shuffle field yet
        // This is a placeholder until API is updated
      ),
    );
  }

  /// Sync questions and contexts to the server.
  Future<void> _syncQuestionsToServer(
    List<AssignmentQuestionEntity> questions,
  ) async {
    final repository = ref.read(assignmentRepositoryProvider);

    final contexts =
        ref.read(assignmentContextsControllerProvider(assignmentId)).value ??
        [];

    final request = AssignmentUpdateRequest(
      questions: questions.map((q) => q.toRequest()).toList(),
      contexts: contexts.map((c) => c.toRequest()).toList(),
    );

    await repository.updateAssignment(assignmentId, request);
  }
}

/// Controller for creating a new Assignment.
class CreateAssignmentController extends AsyncNotifier<AssignmentEntity?> {
  @override
  FutureOr<AssignmentEntity?> build() {
    // Initial state - no assignment created yet
    return null;
  }

  /// Creates a new assignment and refreshes the list.
  /// Returns the created assignment entity.
  Future<AssignmentEntity> createAssignment(
    AssignmentCreateRequest request,
  ) async {
    state = const AsyncLoading();

    final repository = ref.read(assignmentRepositoryProvider);
    final createdAssignment = await repository.createAssignment(request);

    // Update state with created assignment
    state = AsyncData(createdAssignment);

    // Refresh the assignments list
    ref.invalidate(assignmentsControllerProvider);

    return createdAssignment;
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
