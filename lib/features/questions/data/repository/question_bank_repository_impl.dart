import 'package:datn_mobile/features/questions/data/dto/question_bank_item_dto_mapper.dart';
import 'package:datn_mobile/features/questions/data/dto/question_request_mapper.dart';
import 'package:datn_mobile/features/questions/data/source/question_bank_remote_source.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_create_request_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_update_request_entity.dart';
import 'package:datn_mobile/features/questions/domain/repository/question_bank_repository.dart';
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
    String? sortBy,
    String? sortDirection,
    String? grade,
    String? chapter,
  }) async {
    final response = await _remoteSource.getQuestions(
      bankType: bankType.name,
      page: page,
      pageSize: pageSize,
      search: search,
      sortBy: sortBy,
      sortDirection: sortDirection,
      grade: grade,
      chapter: chapter,
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
}
