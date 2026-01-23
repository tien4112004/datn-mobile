import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_create_request_entity.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_update_request_entity.dart';

/// Repository interface for question bank operations.
abstract class QuestionBankRepository {
  /// Fetches paginated list of questions from question bank.
  Future<List<QuestionBankItemEntity>> getQuestions({
    required BankType bankType,
    int page = 1,
    int pageSize = 10,
    String? search,
    String? grade,
    String? chapter,
    String? difficulty,
    String? subject,
    String? type,
    String? sortBy,
    String? sortDirection,
  });

  /// Gets a single question by ID.
  Future<QuestionBankItemEntity> getQuestionById(String id);

  /// Creates one or more questions.
  /// Returns a result with successful and failed items.
  Future<
    ({
      List<QuestionBankItemEntity> successful,
      List<({int index, String title, String error})> failed,
      int totalProcessed,
      int totalSuccessful,
      int totalFailed,
    })
  >
  createQuestions(List<QuestionCreateRequestEntity> requests);

  /// Updates an existing question.
  Future<QuestionBankItemEntity> updateQuestion(
    String id,
    QuestionUpdateRequestEntity updates,
  );

  /// Deletes a question permanently.
  Future<void> deleteQuestion(String id);
}
