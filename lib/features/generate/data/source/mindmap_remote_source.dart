import 'package:datn_mobile/features/generate/data/dto/mindmap_generate_request_dto.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'mindmap_remote_source.g.dart';

/// Remote source for Mindmap API endpoints
@RestApi()
abstract class MindmapRemoteSource {
  factory MindmapRemoteSource(Dio dio, {String baseUrl}) = _MindmapRemoteSource;

  /// POST /mindmaps/generate
  /// Generate a mindmap from a topic using AI
  @POST("/mindmaps/generate")
  Future<ServerResponseDto<String>> generateMindmap(
    @Body() MindmapGenerateRequestDto request,
  );
}
