import 'package:AIPrimary/features/questions/data/dto/generate_questions_request_dto.dart';
import 'package:AIPrimary/features/questions/data/dto/generated_questions_response_dto.dart';
import 'package:AIPrimary/features/questions/data/dto/publish_request_dto.dart';
import 'package:AIPrimary/features/questions/data/dto/question_bank_response_dto.dart';
import 'package:AIPrimary/features/questions/data/dto/question_bank_item_dto.dart';
import 'package:AIPrimary/features/questions/data/dto/question_batch_response_dto.dart';
import 'package:AIPrimary/features/questions/data/dto/question_create_request_dto.dart';
import 'package:AIPrimary/features/questions/data/dto/question_update_request_dto.dart';
import 'package:AIPrimary/features/questions/data/dto/chapter_response_dto.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
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
    @Query('grade') String? grade,
    @Query('chapter') String? chapter,
    @Query('difficulty') String? difficulty,
    @Query('subject') String? subject,
    @Query('type') String? type,
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

  /// Get list of chapters based on grade and subject.
  @GET('/chapters')
  Future<ServerResponseDto<List<ChapterResponseDto>>> getChapters({
    @Query('grade') String? grade,
    @Query('subject') String? subject,
  });

  /// Generate questions using AI based on topic, grade, subject and difficulty requirements.
  @POST('/question-bank/generate')
  Future<ServerResponseDto<GeneratedQuestionsResponseDto>> generateQuestions(
    @Body() GenerateQuestionsRequestDto request,
  );

  /// Submit a question for review to be published to the public bank.
  @POST('/questions/publish/{questionId}')
  Future<ServerResponseDto<PublishRequestDto>> publishQuestion(
    @Path('questionId') String questionId,
  );
}
