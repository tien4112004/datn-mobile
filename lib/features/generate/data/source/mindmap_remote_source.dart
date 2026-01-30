import 'package:AIPrimary/features/generate/data/dto/mindmap_generate_request_dto.dart';
import 'package:AIPrimary/features/generate/data/dto/mindmap_node_content_dto.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
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
  Future<ServerResponseDto<MindmapNodeContentDto>> generateMindmap(
    @Body() MindmapGenerateRequestDto request,
  );
}
