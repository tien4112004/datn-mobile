import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_request_model.freezed.dart';
part 'checkout_request_model.g.dart';

@freezed
abstract class CheckoutRequestModel with _$CheckoutRequestModel {
  const factory CheckoutRequestModel({
    required int amount,
    String? description,
    String? referenceCode,
    String? gate, // SEPAY or PAYOS
    String? successUrl,
    String? errorUrl,
    String? cancelUrl,
  }) = _CheckoutRequestModel;

  factory CheckoutRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestModelFromJson(json);
}
