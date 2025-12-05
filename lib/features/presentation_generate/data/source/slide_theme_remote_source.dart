import 'package:datn_mobile/features/presentation_generate/data/dto/slide_theme_dto.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'slide_theme_remote_source.g.dart';

/// Remote data source for fetching slide themes from the API
@RestApi()
abstract class SlideThemeRemoteSource {
  factory SlideThemeRemoteSource(Dio dio, {String baseUrl}) =
      _SlideThemeRemoteSource;

  /// Fetch list of available slide themes
  /// GET /slide-themes
  @GET("/slide-themes")
  Future<ServerResponseDto<List<SlideThemeDto>>> getSlideThemes({
    @Query("page") int page = 1,
    @Query("pageSize") int pageSize = 10,
  });
}
