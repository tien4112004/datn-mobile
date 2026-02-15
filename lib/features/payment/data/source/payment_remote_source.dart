import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_request_model.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_response_model.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';
import 'package:AIPrimary/features/payment/data/models/paginated_transaction_response_model.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';

part 'payment_remote_source.g.dart';

@RestApi()
abstract class PaymentRemoteSource {
  factory PaymentRemoteSource(Dio dio, {String baseUrl}) = _PaymentRemoteSource;

  @POST('/payments/checkout/create')
  @Headers({'Content-Type': 'application/json'})
  Future<ServerResponseDto<CheckoutResponseModel>> createCheckout(
    @Body() CheckoutRequestModel request,
  );

  @GET('/payments/transaction/{transactionId}')
  Future<ServerResponseDto<TransactionDetailsModel>> getTransactionDetails(
    @Path('transactionId') String transactionId,
  );

  @GET('/payments/user/transactions')
  Future<ServerResponseDto<PaginatedTransactionResponseModel>>
  getUserTransactions(@Query('page') int page, @Query('size') int size);
}
