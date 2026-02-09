import 'package:AIPrimary/features/generate/data/dto/example_prompt_dto.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'example_prompt_remote_source.g.dart';

@RestApi()
abstract class ExamplePromptRemoteSource {
  factory ExamplePromptRemoteSource(Dio dio, {String baseUrl}) =
      _ExamplePromptRemoteSource;

  /// Fetch example prompts by type and language
  /// GET /example-prompts?type=MINDMAP|PRESENTATION|IMAGE&language=vi|en
  @GET("/example-prompts")
  Future<ServerResponseDto<List<ExamplePromptDto>>> getExamplePrompts({
    @Query("type") required String type,
    @Query("language") String? language,
  });
}
