import 'package:AIPrimary/features/coins/data/models/user_coin_model.dart';
import 'package:AIPrimary/features/coins/data/models/token_usage_stats_model.dart';
import 'package:AIPrimary/features/coins/data/models/coin_usage_transaction_model.dart';

abstract class CoinsRepository {
  Future<UserCoinModel> getUserCoins(String userId);
  Future<List<CoinUsageTransactionModel>> getCoinHistory({
    required String userId,
    int page = 0,
    int size = 20,
  });
  Future<TokenUsageStatsModel> getTokenUsageStats();
  Future<List<TokenUsageStatsModel>> getTokenUsageByModel();
  Future<List<TokenUsageStatsModel>> getTokenUsageByRequestType();
}
