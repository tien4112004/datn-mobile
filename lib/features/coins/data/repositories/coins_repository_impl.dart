import 'package:AIPrimary/features/coins/data/repositories/coins_repository.dart';
import 'package:AIPrimary/features/coins/data/source/coins_remote_source.dart';
import 'package:AIPrimary/features/coins/data/models/user_coin_model.dart';
import 'package:AIPrimary/features/coins/data/models/token_usage_stats_model.dart';
import 'package:AIPrimary/features/coins/data/models/coin_usage_transaction_model.dart';

class CoinsRepositoryImpl implements CoinsRepository {
  final CoinsRemoteSource _remoteSource;

  CoinsRepositoryImpl(this._remoteSource);

  @override
  Future<UserCoinModel> getUserCoins(String userId) async {
    return await _remoteSource.getUserCoins(userId);
  }

  @override
  Future<List<CoinUsageTransactionModel>> getCoinHistory({
    required String userId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _remoteSource.getCoinHistory(userId, page, size);
    return response.data ?? [];
  }

  @override
  Future<TokenUsageStatsModel> getTokenUsageStats() async {
    final response = await _remoteSource.getTokenUsageStats();
    if (response.data == null) {
      throw Exception('Failed to load token usage stats');
    }
    return response.data!;
  }

  @override
  Future<List<TokenUsageStatsModel>> getTokenUsageByModel() async {
    final response = await _remoteSource.getTokenUsageByModel();
    return response.data ?? [];
  }

  @override
  Future<List<TokenUsageStatsModel>> getTokenUsageByRequestType() async {
    final response = await _remoteSource.getTokenUsageByRequestType();
    return response.data ?? [];
  }
}
