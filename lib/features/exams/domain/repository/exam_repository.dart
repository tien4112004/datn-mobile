import 'package:datn_mobile/features/exams/domain/entity/exam_entity.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:datn_mobile/features/exams/domain/entity/matrix_item_entity.dart';

/// Repository interface for exam data operations.
abstract class ExamRepository {
  /// Fetches paginated list of exams with filters.
  Future<List<ExamEntity>> getExams({
    int page = 1,
    int limit = 20,
    ExamStatus? status,
    String? topic,
    GradeLevel? gradeLevel,
  });

  /// Gets a single exam by ID.
  Future<ExamEntity> getExamById(String examId);

  /// Creates a new exam in draft status.
  Future<ExamEntity> createExam({
    required String title,
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int? timeLimitMinutes,
  });

  /// Updates an existing exam.
  Future<ExamEntity> updateExam({
    required String examId,
    String? title,
    String? description,
    int? timeLimitMinutes,
  });

  /// Deletes an exam (only if not assigned to any class).
  Future<void> deleteExam(String examId);

  /// Archives an exam (soft delete).
  Future<void> archiveExam(String examId);

  /// Duplicates an existing exam.
  Future<ExamEntity> duplicateExam(String examId);

  /// Generates exam matrix using AI (streaming response).
  Stream<List<MatrixItemEntity>> generateMatrix({
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    String? content,
    required int totalQuestions,
    required int totalPoints,
    List<QuestionType>? questionTypes,
  });

  /// Generates questions based on approved matrix (streaming progress).
  Stream<GenerationProgress> generateQuestions({
    required String examId,
    required List<MatrixItemEntity> matrix,
  });

  /// Exports exam as PDF.
  Future<List<int>> exportExamPdf({
    required String examId,
    bool includeAnswers = false,
    bool includeExplanations = false,
  });
}

/// Progress information for question generation.
class GenerationProgress {
  final String status; // GENERATING, COMPLETED, ERROR
  final int current;
  final int total;
  final String message;

  const GenerationProgress({
    required this.status,
    required this.current,
    required this.total,
    required this.message,
  });

  bool get isCompleted => status == 'COMPLETED';
  bool get hasError => status == 'ERROR';
  double get progress => total > 0 ? current / total : 0;
}
