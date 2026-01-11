import 'package:datn_mobile/features/questions/data/dto/question_bank_response_dto.dart';
import 'package:datn_mobile/features/questions/data/dto/question_bank_item_dto.dart';
import 'package:datn_mobile/features/questions/data/dto/question_batch_response_dto.dart';
import 'package:datn_mobile/features/questions/data/dto/question_create_request_dto.dart';
import 'package:datn_mobile/features/questions/data/dto/question_update_request_dto.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'question_bank_remote_source.g.dart';

/// Remote data source for question bank API calls.
@RestApi()
abstract class QuestionBankRemoteSource {
  factory QuestionBankRemoteSource(Dio dio, {String baseUrl}) =
      _QuestionBankRemoteSource;

  /// Get paginated list of questions.
  @GET('/question-bank')
  Future<QuestionBankResponseDto> getQuestions({
    @Query('bankType') required String bankType,
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 10,
    @Query('search') String? search,
    @Query('sortBy') String? sortBy,
    @Query('sortDirection') String? sortDirection,
  });

  /// Get single question by ID.
  @GET('/question-bank/{id}')
  Future<ServerResponseDto<QuestionBankItemDto>> getQuestionById(
    @Path('id') String id,
  );

  /// Create questions (batch).
  @POST('/question-bank')
  Future<QuestionBatchResponseDto> createQuestions(
    @Body() List<QuestionCreateRequestDto> requests,
  );

  /// Update question.
  @PUT('/question-bank/{id}')
  Future<ServerResponseDto<QuestionBankItemDto>> updateQuestion(
    @Path('id') String id,
    @Body() QuestionUpdateRequestDto updates,
  );

  /// Delete question.
  @DELETE('/question-bank/{id}')
  Future<void> deleteQuestion(@Path('id') String id);
}
