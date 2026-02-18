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

  /// Standard dimensions — always show all 3 difficulties and 4 question types.
  static const _standardDifficulties = [
    'KNOWLEDGE',
    'COMPREHENSION',
    'APPLICATION',
  ];
  static const _standardQuestionTypes = [
    'MULTIPLE_CHOICE',
    'FILL_IN_BLANK',
    'MATCHING',
    'OPEN_ENDED',
  ];

  @override
  Future<AssignmentEntity> build() async {
    final assignment = await _fetchAssignment(assignmentId);
    // Normalize matrix to ensure all standard dimensions are present
    if (assignment.matrix != null) {
      return assignment.copyWith(matrix: _normalizeMatrix(assignment.matrix!));
    }
    return assignment;
  }

  Future<AssignmentEntity> _fetchAssignment(String assignmentId) async {
    final repository = ref.read(assignmentRepositoryProvider);
    return repository.getAssignmentById(assignmentId);
  }

  /// Ensures the matrix has all 3 difficulties and 4 question types.
  /// Copies existing cell values to their correct positions; missing cells get "0:0".
  ApiMatrixEntity _normalizeMatrix(ApiMatrixEntity matrix) {
    final existingDiffs = matrix.dimensions.difficulties;
    final existingTypes = matrix.dimensions.questionTypes;

    // If already standard, return as-is
    if (_listEquals(existingDiffs, _standardDifficulties) &&
        _listEquals(existingTypes, _standardQuestionTypes)) {
      return matrix;
    }

    // Build index maps: existing dimension value → existing index
    final diffIndexMap = <String, int>{};
    for (int i = 0; i < existingDiffs.length; i++) {
      diffIndexMap[existingDiffs[i]] = i;
    }
    final typeIndexMap = <String, int>{};
    for (int i = 0; i < existingTypes.length; i++) {
      typeIndexMap[existingTypes[i]] = i;
    }

    // Rebuild matrix with standard dimensions
    final newMatrix = <List<List<String>>>[];
    for (int t = 0; t < matrix.matrix.length; t++) {
      final topicRow = <List<String>>[];
      for (final stdDiff in _standardDifficulties) {
        final diffRow = <String>[];
        for (final stdType in _standardQuestionTypes) {
          final oldDiffIdx = diffIndexMap[stdDiff];
          final oldTypeIdx = typeIndexMap[stdType];
          if (oldDiffIdx != null &&
              oldTypeIdx != null &&
              t < matrix.matrix.length &&
              oldDiffIdx < matrix.matrix[t].length &&
              oldTypeIdx < matrix.matrix[t][oldDiffIdx].length) {
            diffRow.add(matrix.matrix[t][oldDiffIdx][oldTypeIdx]);
          } else {
            diffRow.add('0:0');
          }
        }
        topicRow.add(diffRow);
      }
      newMatrix.add(topicRow);
    }

    return matrix.copyWith(
      dimensions: MatrixDimensions(
        topics: matrix.dimensions.topics,
        difficulties: _standardDifficulties,
        questionTypes: _standardQuestionTypes,
      ),
      matrix: newMatrix,
    );
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
    int topicIndex,
    int difficultyIndex,
    int questionTypeIndex,
    String cellValue,
  ) async {
    final currentAssignment = await future;
    if (currentAssignment.matrix == null) return;

    final newMatrix = currentAssignment.matrix!.deepCopyMatrix();
    newMatrix[topicIndex][difficultyIndex][questionTypeIndex] = cellValue;

    // Recalculate totals from all cells
    int totalCount = 0;
    double totalPts = 0.0;
    for (final topic in newMatrix) {
      for (final difficulty in topic) {
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

  /// Imports a matrix template, replacing the current assignment matrix.
  /// Local state update only — server sync happens when user presses Save.
  Future<void> importMatrixTemplate(ApiMatrixEntity templateMatrix) async {
    final currentAssignment = await future;

    state = AsyncData(
      currentAssignment.copyWith(matrix: _normalizeMatrix(templateMatrix)),
    );
  }

  /// Add a new topic to the matrix dimensions and append an empty row.
  Future<void> addTopic(String name) async {
    final currentAssignment = await future;
    if (currentAssignment.matrix == null) return;

    final matrixData = currentAssignment.matrix!;
    final dims = matrixData.dimensions;

    // Create new topic
    final newTopic = MatrixDimensionTopic(name: name);

    // Append topic to dimensions
    final newTopics = [...dims.topics, newTopic];
    final newDimensions = MatrixDimensions(
      topics: newTopics,
      difficulties: dims.difficulties,
      questionTypes: dims.questionTypes,
    );

    // Append empty row to matrix
    final newMatrix = matrixData.deepCopyMatrix();
    newMatrix.add(
      List.generate(
        dims.difficulties.length,
        (_) => List.filled(dims.questionTypes.length, '0:0'),
      ),
    );

    state = AsyncData(
      currentAssignment.copyWith(
        matrix: matrixData.copyWith(
          dimensions: newDimensions,
          matrix: newMatrix,
        ),
      ),
    );
  }

  /// Remove a topic from the matrix dimensions and its corresponding row.
  /// Also removes questions associated with the topic.
  Future<void> removeTopic(int topicIndex) async {
    final currentAssignment = await future;
    if (currentAssignment.matrix == null) return;

    final matrixData = currentAssignment.matrix!;
    final dims = matrixData.dimensions;

    // Guard: minimum 1 topic
    if (dims.topics.length <= 1) return;
    if (topicIndex < 0 || topicIndex >= dims.topics.length) return;

    final removedTopic = dims.topics[topicIndex];

    // Remove topic from dimensions
    final newTopics = [...dims.topics]..removeAt(topicIndex);
    final newDimensions = MatrixDimensions(
      topics: newTopics,
      difficulties: dims.difficulties,
      questionTypes: dims.questionTypes,
    );

    // Remove corresponding row from matrix
    final newMatrix = matrixData.deepCopyMatrix()..removeAt(topicIndex);

    // Recalculate totals
    int totalCount = 0;
    double totalPts = 0.0;
    for (final topic in newMatrix) {
      for (final difficulty in topic) {
        for (final cell in difficulty) {
          final parsed = parseCellValue(cell);
          totalCount += parsed.count;
          totalPts += parsed.points;
        }
      }
    }

    // Remove questions with matching topicId
    final updatedQuestions = removedTopic.id != null
        ? currentAssignment.questions
              .where((q) => q.topicId != removedTopic.id)
              .toList()
        : currentAssignment.questions;

    state = AsyncData(
      currentAssignment.copyWith(
        matrix: matrixData.copyWith(
          dimensions: newDimensions,
          matrix: newMatrix,
          totalQuestions: totalCount,
          totalPoints: totalPts.toInt(),
        ),
        questions: updatedQuestions,
      ),
    );
  }

  /// Update a topic's properties (name, chapters, hasContext).
  Future<void> updateTopic(
    int topicIndex, {
    String? name,
    List<String>? chapters,
    bool? hasContext,
  }) async {
    final currentAssignment = await future;
    if (currentAssignment.matrix == null) return;

    final matrixData = currentAssignment.matrix!;
    final dims = matrixData.dimensions;

    if (topicIndex < 0 || topicIndex >= dims.topics.length) return;

    final existing = dims.topics[topicIndex];
    final updated = MatrixDimensionTopic(
      id: existing.id,
      name: name ?? existing.name,
      chapters: chapters ?? existing.chapters,
      hasContext: hasContext ?? existing.hasContext,
    );

    final newTopics = [...dims.topics];
    newTopics[topicIndex] = updated;

    final newDimensions = MatrixDimensions(
      topics: newTopics,
      difficulties: dims.difficulties,
      questionTypes: dims.questionTypes,
    );

    state = AsyncData(
      currentAssignment.copyWith(
        matrix: matrixData.copyWith(dimensions: newDimensions),
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

/// Controller for managing assignment loaded by post ID.
class AssignmentPostController extends AsyncNotifier<AssignmentEntity> {
  final String _postId;

  AssignmentPostController({required String postId}) : _postId = postId;

  @override
  Future<AssignmentEntity> build() async {
    return _fetchAssignmentByPostId();
  }

  Future<AssignmentEntity> _fetchAssignmentByPostId() async {
    final repository = ref.read(assignmentRepositoryProvider);
    return repository.getAssignmentByPostId(_postId);
  }

  /// Refreshes the assignment details.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAssignmentByPostId);
  }
}
