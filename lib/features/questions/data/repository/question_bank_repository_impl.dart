import 'package:AIPrimary/features/questions/data/dto/generate_questions_request_dto.dart';
import 'package:AIPrimary/features/questions/data/dto/question_bank_item_dto_mapper.dart';
import 'package:AIPrimary/features/questions/data/dto/question_request_mapper.dart';
import 'package:AIPrimary/features/questions/data/source/question_bank_remote_source.dart';
import 'package:AIPrimary/features/questions/domain/entity/generate_questions_request_entity.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_create_request_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_update_request_entity.dart';
import 'package:AIPrimary/features/questions/domain/repository/question_bank_repository.dart';
import 'package:flutter/material.dart';

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
    String? grade,
    String? chapter,
    String? difficulty,
    String? subject,
    String? type,
    String? sortBy,
    String? sortDirection,
  }) async {
    final response = await _remoteSource.getQuestions(
      bankType: bankType.name,
      page: page,
      pageSize: pageSize,
      search: search,
      grade: grade,
      chapter: chapter,
      difficulty: difficulty,
      subject: subject,
      type: type,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );

    return response.data.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<QuestionBankItemEntity> getQuestionById(String id) async {
    final response = await _remoteSource.getQuestionById(id);
    if (response.data == null) {
      throw Exception('Question not found');
    }
    return response.data!.toEntity();
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
    debugPrint("Start to create questions: ${dtos.toString()}");
    final response = await _remoteSource.createQuestions(dtos);
    debugPrint(
      "End to create questions: ${response.data.successful.toString()}",
    );

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
    final response = await _remoteSource.updateQuestion(id, dto);
    if (response.data == null) {
      throw Exception('Failed to update question');
    }
    return response.data!.toEntity();
  }

  @override
  Future<void> deleteQuestion(String id) async {
    await _remoteSource.deleteQuestion(id);
  }

  @override
  Future<List<QuestionBankItemEntity>> generateQuestions(
    GenerateQuestionsRequestEntity request,
  ) async {
    final dto = GenerateQuestionsRequestDto(
      topic: request.topic,
      grade: request.grade.apiValue,
      subject: request.subject.apiValue,
      questionsPerDifficulty: request.questionsPerDifficulty.map(
        (difficulty, count) => MapEntry(difficulty.apiValue, count),
      ),
      questionTypes: request.questionTypes.map((t) => t.apiValue).toList(),
      provider: request.provider,
      model: request.model,
      prompt: request.prompt,
    );

    final response = await _remoteSource.generateQuestions(dto);
    if (response.data == null) {
      throw Exception('Failed to generate questions');
    }
    return response.data!.questions.map((q) => q.toEntity()).toList();
  }

  @override
  Future<void> publishQuestion(String questionId) async {
    await _remoteSource.publishQuestion(questionId);
  }
}
