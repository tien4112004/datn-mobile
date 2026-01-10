import 'package:datn_mobile/features/assignments/data/source/assignment_mock_data_source.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
import 'package:datn_mobile/features/assignments/domain/entity/matrix_item_entity.dart';
import 'package:datn_mobile/features/assignments/domain/repository/assignment_repository.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';

/// Implementation of AssignmentRepository using mock data source.
class AssignmentRepositoryImpl implements AssignmentRepository {
  final AssignmentMockDataSource _mockDataSource;

  AssignmentRepositoryImpl(this._mockDataSource);

  @override
  Future<List<AssignmentEntity>> getAssignments({
    int page = 1,
    int limit = 20,
    AssignmentStatus? status,
    String? topic,
    GradeLevel? gradeLevel,
  }) async {
    return _mockDataSource.getAssignments(
      page: page,
      limit: limit,
      status: status,
      topic: topic,
      gradeLevel: gradeLevel,
    );
  }

  @override
  Future<AssignmentEntity> getAssignmentById(String assignmentId) async {
    return _mockDataSource.getdAssignmentById(assignmentId);
  }

  @override
  Future<AssignmentEntity> createAssignment({
    required String title,
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int? timeLimitMinutes,
    bool shuffleQuestions = false,
  }) async {
    return _mockDataSource.createdAssignment(
      title: title,
      description: description,
      topic: topic,
      gradeLevel: gradeLevel,
      difficulty: difficulty,
      timeLimitMinutes: timeLimitMinutes,
    );
  }

  @override
  Future<AssignmentEntity> updateAssignment({
    required String assignmentId,
    String? title,
    String? description,
    int? timeLimitMinutes,
    bool? shuffleQuestions,
  }) async {
    return _mockDataSource.updatedAssignment(
      assignmentId: assignmentId,
      title: title,
      description: description,
      timeLimitMinutes: timeLimitMinutes,
    );
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    return _mockDataSource.deletedAssignment(assignmentId);
  }

  @override
  Future<void> archiveAssignment(String assignmentId) async {
    return _mockDataSource.archivedAssignment(assignmentId);
  }

  @override
  Future<AssignmentEntity> duplicateAssignment(String assignmentId) async {
    return _mockDataSource.duplicatedAssignment(assignmentId);
  }

  @override
  Stream<List<MatrixItemEntity>> generateMatrix({
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    String? content,
    required int totalQuestions,
    required int totalPoints,
    List<QuestionType>? questionTypes,
  }) {
    return _mockDataSource.generateMatrix(
      topic: topic,
      gradeLevel: gradeLevel,
      difficulty: difficulty,
      content: content,
      totalQuestions: totalQuestions,
      totalPoints: totalPoints,
      questionTypes: questionTypes,
    );
  }

  @override
  Stream<GenerationProgress> generateQuestions({
    required String assignmentId,
    required List<MatrixItemEntity> matrix,
  }) {
    return _mockDataSource.generateQuestions(
      assignmentId: assignmentId,
      matrix: matrix,
    );
  }

  @override
  Future<List<int>> exportAssignmentPdf({
    required String assignmentId,
    bool includeAnswers = false,
    bool includeExplanations = false,
  }) async {
    return _mockDataSource.exportAssignmentPdf(
      assignmentId: assignmentId,
      includeAnswers: includeAnswers,
      includeExplanations: includeExplanations,
    );
  }
}
