import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_callback_result_model.freezed.dart';

/// Model for handling payment callback results
@freezed
abstract class PaymentCallbackResultModel with _$PaymentCallbackResultModel {
  const factory PaymentCallbackResultModel({
    required PaymentCallbackStatus status,
    String? transactionId,
    String? message,
  }) = _PaymentCallbackResultModel;
}

enum PaymentCallbackStatus { success, error, cancelled, pending }
