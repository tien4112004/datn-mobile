import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_dto.dart';

part 'presentation_remote_source.g.dart';

@RestApi()
abstract class PresentationRemoteSource {
  factory PresentationRemoteSource(Dio dio) = _PresentationRemoteSource;

  @POST('/api/presentations/generate')
  Future<PresentationResponseDto> generatePresentation(@Body() PresentationRequestDto request);
}