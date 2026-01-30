import 'package:AIPrimary/features/generate/data/dto/art_style_dto.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'art_style_remote_source.g.dart';

@RestApi()
abstract class ArtStyleRemoteSource {
  factory ArtStyleRemoteSource(Dio dio, {String baseUrl}) =
      _ArtStyleRemoteSource;

  /// Fetch list of available art styles
  /// GET /art-styles
  @GET("/art-styles")
  Future<ServerResponseDto<List<ArtStyleDto>>> getArtStyles({
    @Query("page") int page = 1,
    @Query("pageSize") int pageSize = 50,
  });
}
