import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_response_model.freezed.dart';
part 'checkout_response_model.g.dart';

@freezed
abstract class CheckoutResponseModel with _$CheckoutResponseModel {
  const factory CheckoutResponseModel({
    required String transactionId,
    required String checkoutUrl,
    String? orderInvoiceNumber,
    String? gate,
    String? referenceCode,
    double? amount,
    String? status,
  }) = _CheckoutResponseModel;

  factory CheckoutResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CheckoutResponseModelFromJson(json);
}
