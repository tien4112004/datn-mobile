import 'package:AIPrimary/features/generate/data/dto/image_generation_request_dto.dart';
import 'package:AIPrimary/features/generate/data/dto/image_generation_response_dto.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'image_remote_source.g.dart';

/// Remote source for Image API endpoints
@RestApi()
abstract class ImageRemoteSource {
  factory ImageRemoteSource(Dio dio, {String baseUrl}) = _ImageRemoteSource;

  /// POST /images/generate
  /// Generate an image from a prompt using AI
  @POST("/images/generate")
  Future<ServerResponseDto<ImageGenerationResponseDto>> generateImage(
    @Body() ImageGenerationRequestDto request,
  );
}
