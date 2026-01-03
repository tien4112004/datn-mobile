import 'package:datn_mobile/features/exams/data/source/exam_mock_data_source.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_entity.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:datn_mobile/features/exams/domain/entity/matrix_item_entity.dart';
import 'package:datn_mobile/features/exams/domain/repository/exam_repository.dart';

/// Implementation of ExamRepository using mock data source.
class ExamRepositoryImpl implements ExamRepository {
  final ExamMockDataSource _mockDataSource;

  ExamRepositoryImpl(this._mockDataSource);

  @override
  Future<List<ExamEntity>> getExams({
    int page = 1,
    int limit = 20,
    ExamStatus? status,
    String? topic,
    GradeLevel? gradeLevel,
  }) async {
    return _mockDataSource.getExams(
      page: page,
      limit: limit,
      status: status,
      topic: topic,
      gradeLevel: gradeLevel,
    );
  }

  @override
  Future<ExamEntity> getExamById(String examId) async {
    return _mockDataSource.getExamById(examId);
  }

  @override
  Future<ExamEntity> createExam({
    required String title,
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int? timeLimitMinutes,
  }) async {
    return _mockDataSource.createExam(
      title: title,
      description: description,
      topic: topic,
      gradeLevel: gradeLevel,
      difficulty: difficulty,
      timeLimitMinutes: timeLimitMinutes,
    );
  }

  @override
  Future<ExamEntity> updateExam({
    required String examId,
    String? title,
    String? description,
    int? timeLimitMinutes,
  }) async {
    return _mockDataSource.updateExam(
      examId: examId,
      title: title,
      description: description,
      timeLimitMinutes: timeLimitMinutes,
    );
  }

  @override
  Future<void> deleteExam(String examId) async {
    return _mockDataSource.deleteExam(examId);
  }

  @override
  Future<void> archiveExam(String examId) async {
    return _mockDataSource.archiveExam(examId);
  }

  @override
  Future<ExamEntity> duplicateExam(String examId) async {
    return _mockDataSource.duplicateExam(examId);
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
    required String examId,
    required List<MatrixItemEntity> matrix,
  }) {
    return _mockDataSource.generateQuestions(examId: examId, matrix: matrix);
  }

  @override
  Future<List<int>> exportExamPdf({
    required String examId,
    bool includeAnswers = false,
    bool includeExplanations = false,
  }) async {
    return _mockDataSource.exportExamPdf(
      examId: examId,
      includeAnswers: includeAnswers,
      includeExplanations: includeExplanations,
    );
  }
}
