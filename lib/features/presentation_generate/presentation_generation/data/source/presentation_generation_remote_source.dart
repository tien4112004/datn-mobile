import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/data/dto/presentation_generation_dto.dart';

part 'presentation_generation_remote_source.g.dart';

@RestApi()
abstract class PresentationGenerationRemoteSource {
  factory PresentationGenerationRemoteSource(Dio dio) =
      _PresentationGenerationRemoteSource;

  @POST('/api/presentations/generate')
  Future<PresentationGenerationResponseDto> generatePresentation(
    @Body() PresentationGenerationRequestDto request,
  );
}
