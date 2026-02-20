import 'package:AIPrimary/features/payment/data/models/checkout_request_model.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_response_model.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';

abstract class PaymentRepository {
  Future<CheckoutResponseModel> createCheckout(CheckoutRequestModel request);
  Future<TransactionDetailsModel> getTransactionDetails(String transactionId);
  Future<List<TransactionDetailsModel>> getUserTransactions({
    int page = 1,
    int size = 10,
  });
  Future<void> cancelTransaction(String transactionId);
}
