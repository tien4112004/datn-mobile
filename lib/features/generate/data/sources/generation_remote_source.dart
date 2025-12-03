import 'package:datn_mobile/features/generate/data/dto/request/outline_generate_request.dart';
import 'package:datn_mobile/features/generate/data/dto/response/outline_generate_response.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/error_logger.dart';

part 'generation_remote_source.g.dart';

/// Remote source for content generation API endpoints
/// Supports presentations, images, mindmaps, etc.
@RestApi()
abstract class GenerationRemoteSource {
  factory GenerationRemoteSource(Dio dio, {String baseUrl}) =
      _GenerationRemoteSource;

  /// Generate presentation outline
  /// This endpoint is STREAMING in Phase 2
  /// For Phase 1, returns complete result
  /// In Phase 2, will need to use Dio directly with ResponseType.stream
  @Deprecated('Use Dio directly for streaming in Phase 2')
  @POST("/presentations/outline-generate")
  Future<ServerResponseDto<OutlineGenerateResponse>> generateOutline(
    @Body() OutlineGenerateRequest request,
  );

  // TODO: Phase 2 - Add more endpoints as needed
  // @POST("/images/generate")
  // Future<ServerResponseDto<ImageGenerateResponse>> generateImage(...);

  // @POST("/mindmaps/generate")
  // Future<ServerResponseDto<MindmapGenerateResponse>> generateMindmap(...);
}
