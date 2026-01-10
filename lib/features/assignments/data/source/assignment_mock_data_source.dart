import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
import 'package:datn_mobile/features/assignments/domain/entity/matrix_item_entity.dart';
import 'package:datn_mobile/features/assignments/domain/repository/assignment_repository.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';

/// Mock data source for assignment operations.
/// Simulates API responses for development/testing.
class AssignmentMockDataSource {
  // Simulated database
  final List<AssignmentEntity> _assignments = [];
  int _nextId = 1;

  AssignmentMockDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _assignments.addAll([
      AssignmentEntity(
        assignmentId: '1',
        teacherId: 'teacher-123',
        title: 'Mathematics Final Assignment - Grade 1',
        description:
            'Comprehensive math test covering addition and subtraction',
        topic: 'Mathematics',
        gradeLevel: GradeLevel.grade1,
        status: AssignmentStatus.completed,
        difficulty: Difficulty.easy,
        totalQuestions: 20,
        totalPoints: 100,
        timeLimitMinutes: 60,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 25)),
        shuffleQuestions: true,
      ),
      AssignmentEntity(
        assignmentId: '2',
        teacherId: 'teacher-123',
        title: 'Science Quiz - Plants and Animals',
        description: 'Understanding basic biology concepts',
        topic: 'Science',
        gradeLevel: GradeLevel.grade2,
        status: AssignmentStatus.completed,
        difficulty: Difficulty.medium,
        totalQuestions: 15,
        totalPoints: 75,
        timeLimitMinutes: 45,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 15)),
        shuffleQuestions: true,
      ),
      AssignmentEntity(
        assignmentId: '3',
        teacherId: 'teacher-123',
        title: 'Reading Comprehension Test',
        description: 'Test reading skills with short stories',
        topic: 'English Language Arts',
        gradeLevel: GradeLevel.grade3,
        status: AssignmentStatus.draft,
        difficulty: Difficulty.medium,
        totalQuestions: 10,
        totalPoints: 50,
        timeLimitMinutes: 40,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
        shuffleQuestions: true,
      ),
      AssignmentEntity(
        assignmentId: '4',
        teacherId: 'teacher-123',
        title: 'Geography Quiz - World Continents',
        description: 'Identify continents and major geographical features',
        topic: 'Social Studies',
        gradeLevel: GradeLevel.grade4,
        status: AssignmentStatus.generating,
        difficulty: Difficulty.hard,
        totalQuestions: 25,
        totalPoints: 100,
        timeLimitMinutes: 50,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        shuffleQuestions: true,
      ),
      AssignmentEntity(
        assignmentId: '5',
        teacherId: 'teacher-123',
        title: 'Kindergarten Color Recognition',
        description: 'Basic color identification and matching',
        topic: 'General Knowledge',
        gradeLevel: GradeLevel.k,
        status: AssignmentStatus.completed,
        difficulty: Difficulty.easy,
        totalQuestions: 10,
        totalPoints: 30,
        timeLimitMinutes: 20,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 40)),
        shuffleQuestions: true,
      ),
    ]);
    _nextId = _assignments.length + 1;
  }

  Future<List<AssignmentEntity>> getAssignments({
    int page = 1,
    int limit = 20,
    AssignmentStatus? status,
    String? topic,
    GradeLevel? gradeLevel,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var filteredAssignments = List<AssignmentEntity>.from(_assignments);

    // Apply filters
    if (status != null) {
      filteredAssignments = filteredAssignments
          .where((e) => e.status == status)
          .toList();
    }
    if (topic != null && topic.isNotEmpty) {
      filteredAssignments = filteredAssignments
          .where((e) => e.topic.toLowerCase().contains(topic.toLowerCase()))
          .toList();
    }
    if (gradeLevel != null) {
      filteredAssignments = filteredAssignments
          .where((e) => e.gradeLevel == gradeLevel)
          .toList();
    }

    // Sort by created date (newest first)
    filteredAssignments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    if (startIndex >= filteredAssignments.length) {
      return [];
    }
    return filteredAssignments.sublist(
      startIndex,
      endIndex > filteredAssignments.length
          ? filteredAssignments.length
          : endIndex,
    );
  }

  Future<AssignmentEntity> getdAssignmentById(String assignmentId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final assignment = _assignments.firstWhere(
      (e) => e.assignmentId == assignmentId,
      orElse: () => throw Exception('Assignment not found'),
    );
    return assignment;
  }

  Future<AssignmentEntity> createdAssignment({
    required String title,
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int? timeLimitMinutes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newAssignment = AssignmentEntity(
      assignmentId: _nextId.toString(),
      teacherId: 'teacher-123',
      title: title,
      description: description,
      topic: topic,
      gradeLevel: gradeLevel,
      status: AssignmentStatus.draft,
      difficulty: difficulty,
      totalQuestions: 0,
      totalPoints: 0,
      timeLimitMinutes: timeLimitMinutes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      shuffleQuestions: true,
    );

    _assignments.insert(0, newAssignment);
    _nextId++;

    return newAssignment;
  }

  Future<AssignmentEntity> updatedAssignment({
    required String assignmentId,
    String? title,
    String? description,
    int? timeLimitMinutes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _assignments.indexWhere(
      (e) => e.assignmentId == assignmentId,
    );
    if (index == -1) {
      throw Exception('Assignment not found');
    }

    final updatedAssignment = _assignments[index].copyWith(
      title: title,
      description: description,
      timeLimitMinutes: timeLimitMinutes,
      updatedAt: DateTime.now(),
    );

    _assignments[index] = updatedAssignment;
    return updatedAssignment;
  }

  Future<void> deletedAssignment(String assignmentId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final assignment = _assignments.firstWhere(
      (e) => e.assignmentId == assignmentId,
      orElse: () => throw Exception('Assignment not found'),
    );

    if (assignment.status != AssignmentStatus.draft) {
      throw Exception('Cannot delete assignment that is not in draft status');
    }

    _assignments.removeWhere((e) => e.assignmentId == assignmentId);
  }

  Future<void> archivedAssignment(String assignmentId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _assignments.indexWhere(
      (e) => e.assignmentId == assignmentId,
    );
    if (index == -1) {
      throw Exception('Assignment not found');
    }

    _assignments[index] = _assignments[index].copyWith(
      status: AssignmentStatus.archived,
      updatedAt: DateTime.now(),
    );
  }

  Future<AssignmentEntity> duplicatedAssignment(String assignmentId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final original = _assignments.firstWhere(
      (e) => e.assignmentId == assignmentId,
      orElse: () => throw Exception('Assignment not found'),
    );

    final duplicated = AssignmentEntity(
      assignmentId: _nextId.toString(),
      teacherId: original.teacherId,
      title: '${original.title} (Copy)',
      description: original.description,
      topic: original.topic,
      gradeLevel: original.gradeLevel,
      status: AssignmentStatus.draft,
      difficulty: original.difficulty,
      totalQuestions: original.totalQuestions,
      totalPoints: original.totalPoints,
      timeLimitMinutes: original.timeLimitMinutes,
      questionOrder: original.questionOrder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      shuffleQuestions: original.shuffleQuestions,
    );

    _assignments.insert(0, duplicated);
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
    required String assignmentId,
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

    // Update assignment status
    final index = _assignments.indexWhere(
      (e) => e.assignmentId == assignmentId,
    );
    if (index != -1) {
      _assignments[index] = _assignments[index].copyWith(
        status: AssignmentStatus.completed,
        totalQuestions: totalQuestions,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<List<int>> exportAssignmentPdf({
    required String assignmentId,
    bool includeAnswers = false,
    bool includeExplanations = false,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Return mock PDF data (empty bytes)
    return List<int>.filled(1024, 0);
  }
}
