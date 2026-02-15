import 'package:AIPrimary/features/payment/data/repositories/payment_repository.dart';
import 'package:AIPrimary/features/payment/data/source/payment_remote_source.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_request_model.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_response_model.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteSource _remoteSource;

  PaymentRepositoryImpl(this._remoteSource);

  @override
  Future<CheckoutResponseModel> createCheckout(
    CheckoutRequestModel request,
  ) async {
    final response = await _remoteSource.createCheckout(request);
    if (response.data == null) {
      throw Exception('Failed to create checkout');
    }
    return response.data!;
  }

  @override
  Future<TransactionDetailsModel> getTransactionDetails(
    String transactionId,
  ) async {
    final response = await _remoteSource.getTransactionDetails(transactionId);
    if (response.data == null) {
      throw Exception('Failed to get transaction details');
    }
    return response.data!;
  }

  @override
  Future<List<TransactionDetailsModel>> getUserTransactions({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _remoteSource.getUserTransactions(page, size);
    // The response.data contains PaginatedTransactionResponseModel with a 'data' field
    return response.data?.data ?? [];
  }
}
