import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
import 'package:datn_mobile/features/assignments/domain/entity/matrix_item_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';

/// Repository interface for assignment data operations.
abstract class AssignmentRepository {
  /// Fetches paginated list of assignments with filters.
  Future<List<AssignmentEntity>> getAssignments({
    int page = 1,
    int limit = 20,
    AssignmentStatus? status,
    String? topic,
    GradeLevel? gradeLevel,
  });

  /// Gets a single assignment by ID.
  Future<AssignmentEntity> getAssignmentById(String assignmentId);

  /// Creates a new assignment in draft status.
  Future<AssignmentEntity> createAssignment({
    required String title,
    String? description,
    required String topic,
    required GradeLevel gradeLevel,
    required Difficulty difficulty,
    int? timeLimitMinutes,
    bool shuffleQuestions = false,
  });

  /// Updates an existing assignment.
  Future<AssignmentEntity> updateAssignment({
    required String assignmentId,
    String? title,
    String? description,
    int? timeLimitMinutes,
    bool? shuffleQuestions,
  });

  /// Deletes an assignment (only if not assigned to any class).
  Future<void> deleteAssignment(String assignmentId);

  /// Archives an assignment (soft delete).
  Future<void> archiveAssignment(String assignmentId);

  /// Duplicates an existing assignment.
  Future<AssignmentEntity> duplicateAssignment(String assignmentId);

  /// Generates assignment matrix using AI (streaming response).
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
    required String assignmentId,
    required List<MatrixItemEntity> matrix,
  });

  /// Exports assignment as PDF.
  Future<List<int>> exportAssignmentPdf({
    required String assignmentId,
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
