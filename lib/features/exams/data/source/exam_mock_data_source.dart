import 'package:datn_mobile/features/exams/domain/entity/exam_entity.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:datn_mobile/features/exams/domain/entity/matrix_item_entity.dart';
import 'package:datn_mobile/features/exams/domain/repository/exam_repository.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';

/// Mock data source for exam operations.
/// Simulates API responses for development/testing.
class ExamMockDataSource {
  // Simulated database
  final List<ExamEntity> _exams = [];
  int _nextId = 1;

  ExamMockDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _exams.addAll([
      ExamEntity(
        examId: '1',
        teacherId: 'teacher-123',
        title: 'Mathematics Final Exam - Grade 1',
        description:
            'Comprehensive math test covering addition and subtraction',
        topic: 'Mathematics',
        gradeLevel: GradeLevel.grade1,
        status: ExamStatus.completed,
        difficulty: Difficulty.easy,
        totalQuestions: 20,
        totalPoints: 100,
        timeLimitMinutes: 60,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 25)),
      ),
      ExamEntity(
        examId: '2',
        teacherId: 'teacher-123',
        title: 'Science Quiz - Plants and Animals',
        description: 'Understanding basic biology concepts',
        topic: 'Science',
        gradeLevel: GradeLevel.grade2,
        status: ExamStatus.completed,
        difficulty: Difficulty.medium,
        totalQuestions: 15,
        totalPoints: 75,
        timeLimitMinutes: 45,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      ExamEntity(
        examId: '3',
        teacherId: 'teacher-123',
        title: 'Reading Comprehension Test',
        description: 'Test reading skills with short stories',
        topic: 'English Language Arts',
        gradeLevel: GradeLevel.grade3,
        status: ExamStatus.draft,
        difficulty: Difficulty.medium,
        totalQuestions: 10,
        totalPoints: 50,
        timeLimitMinutes: 40,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      ExamEntity(
        examId: '4',
        teacherId: 'teacher-123',
        title: 'Geography Quiz - World Continents',
        description: 'Identify continents and major geographical features',
        topic: 'Social Studies',
        gradeLevel: GradeLevel.grade4,
        status: ExamStatus.generating,
        difficulty: Difficulty.hard,
        totalQuestions: 25,
        totalPoints: 100,
        timeLimitMinutes: 50,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ExamEntity(
        examId: '5',
        teacherId: 'teacher-123',
        title: 'Kindergarten Color Recognition',
        description: 'Basic color identification and matching',
        topic: 'General Knowledge',
        gradeLevel: GradeLevel.k,
        status: ExamStatus.completed,
        difficulty: Difficulty.easy,
        totalQuestions: 10,
        totalPoints: 30,
        timeLimitMinutes: 20,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 40)),
      ),
    ]);
    _nextId = _exams.length + 1;
  }

  Future<List<ExamEntity>> getExams({
    int page = 1,
    int limit = 20,
    ExamStatus? status,
    String? topic,
    GradeLevel? gradeLevel,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var filteredExams = List<ExamEntity>.from(_exams);

    // Apply filters
    if (status != null) {
      filteredExams = filteredExams.where((e) => e.status == status).toList();
    }
    if (topic != null && topic.isNotEmpty) {
      filteredExams = filteredExams
          .where((e) => e.topic.toLowerCase().contains(topic.toLowerCase()))
          .toList();
    }
    if (gradeLevel != null) {
      filteredExams = filteredExams
          .where((e) => e.gradeLevel == gradeLevel)
          .toList();
    }

    // Sort by created date (newest first)
    filteredExams.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    if (startIndex >= filteredExams.length) {
      return [];
    }
    return filteredExams.sublist(
      startIndex,
      endIndex > filteredExams.length ? filteredExams.length : endIndex,
    );
  }

  Future<ExamEntity> getExamById(String examId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final exam = _exams.firstWhere(
      (e) => e.examId == examId,
      orElse: () => throw Exception('Exam not found'),
    );
    return exam;
  }

  Future<ExamEntity> createExam({
    required String title,
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int? timeLimitMinutes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newExam = ExamEntity(
      examId: _nextId.toString(),
      teacherId: 'teacher-123',
      title: title,
      description: description,
      topic: topic,
      gradeLevel: gradeLevel,
      status: ExamStatus.draft,
      difficulty: difficulty,
      totalQuestions: 0,
      totalPoints: 0,
      timeLimitMinutes: timeLimitMinutes,
      createdAt: DateTime.now(),
    );

    _exams.insert(0, newExam);
    _nextId++;

    return newExam;
  }

  Future<ExamEntity> updateExam({
    required String examId,
    String? title,
    String? description,
    int? timeLimitMinutes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _exams.indexWhere((e) => e.examId == examId);
    if (index == -1) {
      throw Exception('Exam not found');
    }

    final updatedExam = _exams[index].copyWith(
      title: title,
      description: description,
      timeLimitMinutes: timeLimitMinutes,
      updatedAt: DateTime.now(),
    );

    _exams[index] = updatedExam;
    return updatedExam;
  }

  Future<void> deleteExam(String examId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final exam = _exams.firstWhere(
      (e) => e.examId == examId,
      orElse: () => throw Exception('Exam not found'),
    );

    if (exam.status != ExamStatus.draft) {
      throw Exception('Cannot delete exam that is not in draft status');
    }

    _exams.removeWhere((e) => e.examId == examId);
  }

  Future<void> archiveExam(String examId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _exams.indexWhere((e) => e.examId == examId);
    if (index == -1) {
      throw Exception('Exam not found');
    }

    _exams[index] = _exams[index].copyWith(
      status: ExamStatus.archived,
      updatedAt: DateTime.now(),
    );
  }

  Future<ExamEntity> duplicateExam(String examId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final original = _exams.firstWhere(
      (e) => e.examId == examId,
      orElse: () => throw Exception('Exam not found'),
    );

    final duplicated = ExamEntity(
      examId: _nextId.toString(),
      teacherId: original.teacherId,
      title: '${original.title} (Copy)',
      description: original.description,
      topic: original.topic,
      gradeLevel: original.gradeLevel,
      status: ExamStatus.draft,
      difficulty: original.difficulty,
      totalQuestions: original.totalQuestions,
      totalPoints: original.totalPoints,
      timeLimitMinutes: original.timeLimitMinutes,
      questionOrder: original.questionOrder,
      createdAt: DateTime.now(),
    );

    _exams.insert(0, duplicated);
    _nextId++;

    return duplicated;
  }

  Stream<List<MatrixItemEntity>> generateMatrix({
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    String? content,
    required int totalQuestions,
    required int totalPoints,
    List<QuestionType>? questionTypes,
  }) async* {
    // Simulate streaming response
    await Future.delayed(const Duration(milliseconds: 500));

    final matrix = <MatrixItemEntity>[
      MatrixItemEntity(
        topic: topic,
        questionType: QuestionType.multipleChoice,
        count: (totalQuestions * 0.5).round(),
        pointsEach: (totalPoints ~/ totalQuestions),
        difficulty: difficulty,
        requiresContext: false,
      ),
      MatrixItemEntity(
        topic: topic,
        questionType: QuestionType.matching,
        count: (totalQuestions * 0.3).round(),
        pointsEach: (totalPoints ~/ totalQuestions),
        difficulty: difficulty,
        requiresContext: false,
      ),
      MatrixItemEntity(
        topic: topic,
        questionType: QuestionType.fillInBlank,
        count: (totalQuestions * 0.2).round(),
        pointsEach: (totalPoints ~/ totalQuestions),
        difficulty: difficulty,
        requiresContext: false,
      ),
    ];

    yield matrix;
  }

  Stream<GenerationProgress> generateQuestions({
    required String examId,
    required List<MatrixItemEntity> matrix,
  }) async* {
    final totalQuestions = matrix.fold<int>(0, (sum, item) => sum + item.count);

    for (int i = 0; i <= totalQuestions; i++) {
      await Future.delayed(const Duration(milliseconds: 300));

      yield GenerationProgress(
        status: i < totalQuestions ? 'GENERATING' : 'COMPLETED',
        current: i,
        total: totalQuestions,
        message: i < totalQuestions
            ? 'Generating question $i of $totalQuestions...'
            : 'All questions generated successfully!',
      );
    }

    // Update exam status
    final index = _exams.indexWhere((e) => e.examId == examId);
    if (index != -1) {
      _exams[index] = _exams[index].copyWith(
        status: ExamStatus.completed,
        totalQuestions: totalQuestions,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<List<int>> exportExamPdf({
    required String examId,
    bool includeAnswers = false,
    bool includeExplanations = false,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Return mock PDF data (empty bytes)
    return List<int>.filled(1024, 0);
  }
}
