import 'package:datn_mobile/features/generate/data/dto/model_response.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/error_logger.dart';

part 'models_remote_source.g.dart';

/// Remote source for AI models API endpoints
@RestApi()
abstract class ModelsRemoteSource {
  factory ModelsRemoteSource(Dio dio, {String baseUrl}) = _ModelsRemoteSource;

  /// Get all available AI models
  /// Can filter by modelType query parameter (TEXT or IMAGE)
  @GET("/models")
  Future<ServerResponseDto<List<ModelResponse>>> getModels({
    @Query("modelType") String? modelType,
  });

  /// Get a specific model by ID
  @GET("/models/{id}")
  Future<ServerResponseDto<ModelResponse>> getModelById(@Path() int id);
}
