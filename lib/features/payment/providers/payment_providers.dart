import 'package:flutter/material.dart';
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
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/i18n/strings.g.dart';

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

// Coin packages from backend
final coinPackagesProvider = FutureProvider.autoDispose<List<CoinPackageModel>>(
  (ref) async {
    final repository = ref.watch(paymentRepositoryProvider);
    final t = ref.watch(translationsPod);
    final packages = await repository.getCoinPackages();
    debugPrint('packages: ${packages.first} ');
    return packages
        .map(
          (p) => p.copyWith(
            name: _localizedPackageName(p.name, t),
            isPopular: p.name.toUpperCase() == 'PREMIUM_100K',
          ),
        )
        .toList();
  },
);

String _localizedPackageName(String name, Translations t) {
  final names = t.payment.coinPurchase.packageNames;
  return switch (name.toUpperCase()) {
    'BASIC_20K' => names.basic20k,
    'STARTER_30K' => names.starter30k,
    'STANDARD_50K' => names.standard50k,
    'PREMIUM_100K' => names.premium100k,
    'DELUXE_200K' => names.deluxe200k,
    'ULTIMATE_500K' => names.ultimate500k,
    _ => name,
  };
}

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
