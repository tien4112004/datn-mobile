import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_response_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_response_dto.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'presentation_generate_remote_source.g.dart';

@RestApi()
abstract class PresentationGenerateRemoteSource {
  factory PresentationGenerateRemoteSource(Dio dio, {String baseUrl}) =
      _PresentationGenerateRemoteSource;

  @POST("/api/presentations/outline/generate")
  Future<ServerResponseDto<OutlineGenerateResponse>> generateOutline(
    @Body() OutlineGenerateRequest request,
  );

  @POST("/presentations/generate")
  Future<ServerResponseDto<PresentationGenerateResponse>> generatePresentation(
    @Body() PresentationGenerateRequest request,
  );
}
