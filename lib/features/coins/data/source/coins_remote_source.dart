import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:AIPrimary/features/coins/data/models/user_coin_model.dart';
import 'package:AIPrimary/features/coins/data/models/token_usage_stats_model.dart';
import 'package:AIPrimary/features/coins/data/models/coin_usage_transaction_model.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';

part 'coins_remote_source.g.dart';

@RestApi()
abstract class CoinsRemoteSource {
  factory CoinsRemoteSource(Dio dio, {String baseUrl}) = _CoinsRemoteSource;

  @GET('/payments/{userId}/coins')
  Future<UserCoinModel> getUserCoins(@Path('userId') String userId);

  @GET('/payments/{userId}/history')
  Future<ServerResponseDto<List<CoinUsageTransactionModel>>> getCoinHistory(
    @Path('userId') String userId,
    @Query('page') int page,
    @Query('size') int size,
  );

  @GET('/token-usage/stats')
  Future<ServerResponseDto<TokenUsageStatsModel>> getTokenUsageStats();

  @GET('/token-usage/by-model')
  Future<ServerResponseDto<List<TokenUsageStatsModel>>> getTokenUsageByModel();

  @GET('/token-usage/by-request-type')
  Future<ServerResponseDto<List<TokenUsageStatsModel>>>
  getTokenUsageByRequestType();
}
