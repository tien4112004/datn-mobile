import 'dart:async';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/coins/data/source/coins_remote_source.dart';
import 'package:AIPrimary/features/coins/data/repositories/coins_repository.dart';
import 'package:AIPrimary/features/coins/data/repositories/coins_repository_impl.dart';
import 'package:AIPrimary/features/coins/data/models/user_coin_model.dart';
import 'package:AIPrimary/features/coins/data/models/token_usage_stats_model.dart';
import 'package:AIPrimary/features/coins/data/models/coin_usage_transaction_model.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';

// Remote source provider
final coinsRemoteSourceProvider = Provider<CoinsRemoteSource>((ref) {
  return CoinsRemoteSource(ref.watch(dioPod));
});

// Repository provider
final coinsRepositoryProvider = Provider<CoinsRepository>((ref) {
  return CoinsRepositoryImpl(ref.watch(coinsRemoteSourceProvider));
});

// User coin balance provider with auto-refresh
final userCoinBalanceProvider = FutureProvider.autoDispose<UserCoinModel>((
  ref,
) async {
  final repository = ref.watch(coinsRepositoryProvider);
  final userProfile = ref.watch(userControllerPod);

  if (userProfile.value == null) {
    throw Exception('User not authenticated');
  }

  // Auto-refresh every 30 seconds
  final timer = Timer(const Duration(seconds: 30), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());

  return repository.getUserCoins(userProfile.value!.id);
});

// All coin usage history provider (fetches all pages)
final userAllCoinHistoryProvider =
    FutureProvider<List<CoinUsageTransactionModel>>((ref) async {
      final repository = ref.watch(coinsRepositoryProvider);
      final userProfile = ref.watch(userControllerPod);

      if (userProfile.value == null) {
        throw Exception('User not authenticated');
      }

      List<CoinUsageTransactionModel> allHistory = [];
      int currentPage = 0;
      bool hasMore = true;

      while (hasMore) {
        final page = await repository.getCoinHistory(
          userId: userProfile.value!.id,
          page: currentPage,
          size: 100,
        );
        if (page.isEmpty || page.length < 100) {
          hasMore = false;
        }
        allHistory.addAll(page);
        currentPage++;
      }

      return allHistory;
    });

// Token usage stats provider
final tokenUsageStatsProvider =
    FutureProvider.autoDispose<TokenUsageStatsModel>((ref) async {
      final repository = ref.watch(coinsRepositoryProvider);
      return repository.getTokenUsageStats();
    });

final tokenUsageByModelProvider = FutureProvider<List<TokenUsageStatsModel>>((
  ref,
) async {
  final repository = ref.watch(coinsRepositoryProvider);
  return repository.getTokenUsageByModel();
});

final tokenUsageByRequestTypeProvider =
    FutureProvider<List<TokenUsageStatsModel>>((ref) async {
      final repository = ref.watch(coinsRepositoryProvider);
      return repository.getTokenUsageByRequestType();
    });
