part of 'controller_provider.dart';

/// Controller for managing the exam list state.
class ExamsController extends AsyncNotifier<List<ExamEntity>> {
  ExamStatus? _statusFilter;
  String? _topicFilter;
  GradeLevel? _gradeLevelFilter;

  @override
  Future<List<ExamEntity>> build() async {
    return _fetchExams();
  }

  Future<List<ExamEntity>> _fetchExams() async {
    final repository = ref.read(examRepositoryProvider);
    return repository.getExams(
      status: _statusFilter,
      topic: _topicFilter,
      gradeLevel: _gradeLevelFilter,
    );
  }

  /// Refreshes the exam list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchExams);
  }

  /// Filters exams by status.
  Future<void> filterByStatus(ExamStatus? status) async {
    _statusFilter = status;
    await refresh();
  }

  /// Filters exams by topic.
  Future<void> filterByTopic(String? topic) async {
    _topicFilter = topic;
    await refresh();
  }

  /// Filters exams by grade level.
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

/// Controller for managing a single exam detail.
class DetailExamController extends AsyncNotifier<ExamEntity> {
  final String examId;

  DetailExamController({required this.examId});

  @override
  Future<ExamEntity> build() async {
    return _fetchExam(examId);
  }

  Future<ExamEntity> _fetchExam(String examId) async {
    final repository = ref.read(examRepositoryProvider);
    return repository.getExamById(examId);
  }

  /// Refreshes the exam details.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchExam(examId));
  }
}

/// Controller for creating a new exam.
class CreateExamController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Creates a new exam and refreshes the list.
  Future<void> createExam({
    required String title,
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int? timeLimitMinutes,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(examRepositoryProvider);
      await repository.createExam(
        title: title,
        description: description,
        topic: topic,
        gradeLevel: gradeLevel,
        difficulty: difficulty,
        timeLimitMinutes: timeLimitMinutes,
      );
      // Refresh the exams list
      ref.invalidate(examsControllerProvider);
    });
  }
}

/// Controller for updating an exam.
class UpdateExamController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Updates an exam and refreshes the list.
  Future<void> updateExam({
    required String examId,
    String? title,
    String? description,
    int? timeLimitMinutes,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(examRepositoryProvider);
      await repository.updateExam(
        examId: examId,
        title: title,
        description: description,
        timeLimitMinutes: timeLimitMinutes,
      );
      // Refresh the exams list and detail
      ref.invalidate(examsControllerProvider);
      ref.invalidate(detailExamControllerProvider(examId));
    });
  }
}

/// Controller for deleting an exam.
class DeleteExamController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Deletes an exam and refreshes the list.
  Future<void> deleteExam(String examId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(examRepositoryProvider);
      await repository.deleteExam(examId);
      // Refresh the exams list
      ref.invalidate(examsControllerProvider);
    });
  }
}

/// Controller for archiving an exam.
class ArchiveExamController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Archives an exam and refreshes the list.
  Future<void> archiveExam(String examId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(examRepositoryProvider);
      await repository.archiveExam(examId);
      // Refresh the exams list and detail
      ref.invalidate(examsControllerProvider);
      ref.invalidate(detailExamControllerProvider(examId));
    });
  }
}

/// Controller for duplicating an exam.
class DuplicateExamController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Duplicates an exam and refreshes the list.
  Future<void> duplicateExam(String examId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(examRepositoryProvider);
      await repository.duplicateExam(examId);
      // Refresh the exams list
      ref.invalidate(examsControllerProvider);
    });
  }
}

/// Controller for generating exam matrix.
class GenerateMatrixController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Generates exam matrix using AI.
  Stream<List<MatrixItemEntity>> generateMatrix({
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    String? content,
    required int totalQuestions,
    required int totalPoints,
    List<QuestionType>? questionTypes,
  }) {
    final repository = ref.read(examRepositoryProvider);
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
    required String examId,
    required List<MatrixItemEntity> matrix,
  }) {
    final repository = ref.read(examRepositoryProvider);
    return repository.generateQuestions(examId: examId, matrix: matrix);
  }
}
