import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/payment/data/source/payment_remote_source.dart';
import 'package:AIPrimary/features/payment/data/repositories/payment_repository.dart';
import 'package:AIPrimary/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_request_model.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_response_model.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';
import 'package:AIPrimary/features/payment/data/models/coin_package_model.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';

// Remote source provider
final paymentRemoteSourceProvider = Provider<PaymentRemoteSource>((ref) {
  return PaymentRemoteSource(ref.watch(dioPod));
});

// Repository provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(paymentRemoteSourceProvider));
});

// Predefined coin packages (client-side)
final coinPackagesProvider = Provider<List<CoinPackageModel>>((ref) {
  return const [
    CoinPackageModel(
      id: 'starter',
      name: 'Starter Pack',
      coins: 1000,
      price: 50000, // 50,000 VND
      description: 'Perfect for trying out',
    ),
    CoinPackageModel(
      id: 'popular',
      name: 'Popular Pack',
      coins: 5000,
      price: 200000, // 200,000 VND
      bonusCoins: 500,
      isPopular: true,
      description: 'Best value! +500 bonus coins',
    ),
    CoinPackageModel(
      id: 'premium',
      name: 'Premium Pack',
      coins: 10000,
      price: 350000, // 350,000 VND
      bonusCoins: 1500,
      description: 'Maximum savings! +1,500 bonus coins',
    ),
    CoinPackageModel(
      id: 'ultimate',
      name: 'Ultimate Pack',
      coins: 25000,
      price: 800000, // 800,000 VND
      bonusCoins: 5000,
      description: 'For power users! +5,000 bonus coins',
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

// User transactions provider (paginated)
final userTransactionsProvider = FutureProvider.autoDispose
    .family<List<TransactionDetailsModel>, int>((ref, page) async {
      final repository = ref.watch(paymentRepositoryProvider);
      return repository.getUserTransactions(page: page, size: 10);
    });
