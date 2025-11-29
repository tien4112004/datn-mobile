import 'dart:async';

import 'package:datn_mobile/features/projects/data/dto/presentation_dto.dart';
import 'package:datn_mobile/features/projects/data/dto/presentation_minimal_dto.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'projects_remote_source.g.dart';

@RestApi()
abstract class ProjectsRemoteSource {
  factory ProjectsRemoteSource(Dio dio, {String baseUrl}) =
      _ProjectsRemoteSource;

  @GET("/presentations")
  Future<ServerResponseDto<List<PresentationMinimalDto>>> fetchPresentations();

  @GET("/presentations/{id}")
  Future<ServerResponseDto<PresentationDto>> fetchPresentationById(
    @Path("id") String id,
  );

  @POST("/presentations")
  Future<PresentationDto> createPresentation(
    @Body() PresentationDto presentation,
  );

  // /presentations?page=1&pageSize=20&sort=desc
  @GET("/presentations?page={pageKey}&pageSize={pageSize}&sort={sort}")
  Future<ServerResponseDto<List<PresentationMinimalDto>>>
  fetchPresentationMinimalsPaged({
    @Path("pageKey") int pageKey = 1,
    @Path("pageSize") int pageSize = 10,
    @Path("sort") String sort = "desc",
  });
}
