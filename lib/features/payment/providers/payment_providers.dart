import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/payment/data/source/payment_remote_source.dart';
import 'package:AIPrimary/features/payment/data/repositories/payment_repository.dart';
import 'package:AIPrimary/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_request_model.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_response_model.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';
import 'package:AIPrimary/features/payment/data/models/coin_package_model.dart';
import 'package:AIPrimary/features/payment/domain/services/payment_status_polling_service.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';

// Remote source provider
final paymentRemoteSourceProvider = Provider<PaymentRemoteSource>((ref) {
  return PaymentRemoteSource(ref.watch(dioPod));
});

// Repository provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(paymentRemoteSourceProvider));
});

// Payment status polling service provider
final paymentStatusPollingServiceProvider =
    Provider<PaymentStatusPollingService>((ref) {
      final repository = ref.watch(paymentRepositoryProvider);
      return PaymentStatusPollingService(repository);
    });

// Predefined coin packages (client-side)
final coinPackagesProvider = Provider<List<CoinPackageModel>>((ref) {
  final t = ref.watch(translationsPod);
  return [
    CoinPackageModel(
      id: 'starter',
      name: t.payment.coinPurchase.packages.starter.name,
      coins: 1000,
      price: 50000, // 50,000 VND
      description: t.payment.coinPurchase.packages.starter.description,
    ),
    CoinPackageModel(
      id: 'popular',
      name: t.payment.coinPurchase.packages.popular.name,
      coins: 5000,
      price: 200000, // 200,000 VND
      bonusCoins: 500,
      isPopular: true,
      description: t.payment.coinPurchase.packages.popular.description,
    ),
    CoinPackageModel(
      id: 'premium',
      name: t.payment.coinPurchase.packages.premium.name,
      coins: 10000,
      price: 350000, // 350,000 VND
      bonusCoins: 1500,
      description: t.payment.coinPurchase.packages.premium.description,
    ),
    CoinPackageModel(
      id: 'ultimate',
      name: t.payment.coinPurchase.packages.ultimate.name,
      coins: 25000,
      price: 800000, // 800,000 VND
      bonusCoins: 5000,
      description: t.payment.coinPurchase.packages.ultimate.description,
    ),
  ];
});

// Create checkout provider
final createCheckoutProvider =
    FutureProvider.family<CheckoutResponseModel, CheckoutRequestModel>((
      ref,
      request,
    ) async {
      final repository = ref.watch(paymentRepositoryProvider);
      return repository.createCheckout(request);
    });

// Transaction details provider
final transactionDetailsProvider =
    FutureProvider.family<TransactionDetailsModel, String>((
      ref,
      transactionId,
    ) async {
      final repository = ref.watch(paymentRepositoryProvider);
      return repository.getTransactionDetails(transactionId);
    });

// User transactions provider (paginated - for compatibility)
final userTransactionsProvider = FutureProvider.autoDispose
    .family<List<TransactionDetailsModel>, int>((ref, page) async {
      final repository = ref.watch(paymentRepositoryProvider);
      return repository.getUserTransactions(page: page, size: 10);
    });

// User all transactions provider (fetch all at once)
final userAllTransactionsProvider =
    FutureProvider<List<TransactionDetailsModel>>((ref) async {
      final repository = ref.watch(paymentRepositoryProvider);

      // Fetch all transactions by loading pages until we get all data
      List<TransactionDetailsModel> allTransactions = [];
      int currentPage = 1;
      bool hasMore = true;

      while (hasMore) {
        final pageTransactions = await repository.getUserTransactions(
          page: currentPage,
          size: 100, // Larger page size for efficiency
        );

        if (pageTransactions.isEmpty || pageTransactions.length < 100) {
          hasMore = false;
        }

        allTransactions.addAll(pageTransactions);
        currentPage++;
      }

      return allTransactions;
    });
