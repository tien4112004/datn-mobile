import 'package:datn_mobile/features/questions/data/dto/question_bank_item_dto_mapper.dart';
import 'package:datn_mobile/features/questions/data/dto/question_request_mapper.dart';
import 'package:datn_mobile/features/questions/data/source/question_bank_remote_source.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_create_request_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_update_request_entity.dart';
import 'package:datn_mobile/features/questions/domain/repository/question_bank_repository.dart';

/// Implementation of QuestionBankRepository using remote data source.
class QuestionBankRepositoryImpl implements QuestionBankRepository {
  final QuestionBankRemoteSource _remoteSource;

  QuestionBankRepositoryImpl(this._remoteSource);

  @override
  Future<List<QuestionBankItemEntity>> getQuestions({
    required BankType bankType,
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortDirection,
  }) async {
    // final response = await _remoteSource.getQuestions(
    //   bankType: bankType.name,
    //   page: page,
    //   pageSize: pageSize,
    //   search: search,
    //   sortBy: sortBy,
    //   sortDirection: sortDirection,
    // );

    // return (
    //   items: response.data.map((dto) => dto.toEntity()).toList(),
    //   pagination: response.pagination.toEntity(),
    // );

    // Mockup Question
    return [
      QuestionBankItemEntity(
        id: '1',
        question: const MultipleChoiceQuestion(
          id: '1',
          title: 'Question 1',
          difficulty: Difficulty.easy,
          explanation: 'Explanation for question 1',
          titleImageUrl: 'https://via.placeholder.com/150',
          points: 10,
          data: MultipleChoiceData(
            options: [
              MultipleChoiceOption(id: '1', isCorrect: true, text: 'Option 1'),
              MultipleChoiceOption(id: '2', isCorrect: false, text: 'Option 2'),
            ],
          ),
        ),
        ownerId: 'ownerId',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
      QuestionBankItemEntity(
        id: '2',
        question: const MatchingQuestion(
          id: '2',
          title: 'Question 2',
          difficulty: Difficulty.medium,
          explanation: 'Explanation for question 2',
          titleImageUrl: 'https://via.placeholder.com/150',
          points: 20,
          data: MatchingData(
            pairs: [
              MatchingPair(id: '1', left: 'Left 1', right: 'Right 1'),
              MatchingPair(id: '2', left: 'Left 2', right: 'Right 2'),
            ],
          ),
        ),
        ownerId: 'ownerId',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
      QuestionBankItemEntity(
        id: '3',
        question: const OpenEndedQuestion(
          id: '3',
          title: 'Question 3',
          difficulty: Difficulty.hard,
          explanation: 'Explanation for question 3',
          titleImageUrl: 'https://via.placeholder.com/150',
          points: 30,
          data: OpenEndedData(
            expectedAnswer: 'Expected answer for question 3',
            maxLength: 100,
          ),
        ),
        ownerId: 'ownerId',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
      QuestionBankItemEntity(
        id: '4',
        question: const FillInBlankQuestion(
          id: '4',
          title: 'Question 4',
          difficulty: Difficulty.hard,
          explanation: 'Explanation for question 4',
          titleImageUrl: 'https://via.placeholder.com/150',
          points: 40,
          data: FillInBlankData(
            segments: [
              BlankSegment(id: '1', type: SegmentType.text, content: 'Text 1'),
              BlankSegment(
                id: '2',
                type: SegmentType.blank,
                content: 'Blank 1',
              ),
            ],
          ),
        ),
        ownerId: 'ownerId',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
      QuestionBankItemEntity(
        id: '5',
        question: const FillInBlankQuestion(
          id: '5',
          title: 'Question 5',
          difficulty: Difficulty.hard,
          explanation: 'Explanation for question 5',
          titleImageUrl: 'https://via.placeholder.com/150',
          points: 50,
          data: FillInBlankData(
            segments: [
              BlankSegment(id: '1', type: SegmentType.text, content: 'Text 1'),
              BlankSegment(
                id: '2',
                type: SegmentType.blank,
                content: 'Blank 1',
              ),
            ],
          ),
        ),
        ownerId: 'ownerId',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
    ];
  }

  @override
  Future<QuestionBankItemEntity> getQuestionById(String id) async {
    final dto = await _remoteSource.getQuestionById(id);
    return dto.toEntity();
  }

  @override
  Future<
    ({
      List<QuestionBankItemEntity> successful,
      List<({int index, String title, String error})> failed,
      int totalProcessed,
      int totalSuccessful,
      int totalFailed,
    })
  >
  createQuestions(List<QuestionCreateRequestEntity> requests) async {
    // Convert domain entities to DTOs
    final dtos = requests.map((entity) => entity.toDto()).toList();
    final response = await _remoteSource.createQuestions(dtos);

    return (
      successful: response.data.successful
          .map((dto) => dto.toEntity())
          .toList(),
      failed: response.data.failed
          .map((f) => (index: f.index, title: f.title, error: f.errorMessage))
          .toList(),
      totalProcessed: response.data.totalProcessed,
      totalSuccessful: response.data.totalSuccessful,
      totalFailed: response.data.totalFailed,
    );
  }

  @override
  Future<QuestionBankItemEntity> updateQuestion(
    String id,
    QuestionUpdateRequestEntity updates,
  ) async {
    // Convert domain entity to DTO
    final dto = updates.toDto();
    final result = await _remoteSource.updateQuestion(id, dto);
    return result.toEntity();
  }

  @override
  Future<void> deleteQuestion(String id) async {
    await _remoteSource.deleteQuestion(id);
  }
}
