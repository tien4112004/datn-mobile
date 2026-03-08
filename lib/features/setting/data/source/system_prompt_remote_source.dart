import 'package:AIPrimary/features/setting/data/dto/system_prompt_dto.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/error_logger.dart';

part 'system_prompt_remote_source.g.dart';

@RestApi()
abstract class SystemPromptRemoteSource {
  factory SystemPromptRemoteSource(Dio dio, {String baseUrl}) =
      _SystemPromptRemoteSource;

  @GET('/teacher/system-prompt')
  Future<ServerResponseDto<SystemPromptResponseDto>> getMyPrompt();

  @PUT('/teacher/system-prompt')
  Future<ServerResponseDto<SystemPromptResponseDto>> upsertMyPrompt(
    @Body() SystemPromptRequestDto request,
  );

  @DELETE('/teacher/system-prompt')
  Future<void> deleteMyPrompt();
}
