import 'package:freezed_annotation/freezed_annotation.dart';

part 'coin_usage_transaction_model.freezed.dart';
part 'coin_usage_transaction_model.g.dart';

@freezed
abstract class CoinUsageTransactionModel with _$CoinUsageTransactionModel {
  const factory CoinUsageTransactionModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required String type,
    required String source,
    required int amount,
  }) = _CoinUsageTransactionModel;

  factory CoinUsageTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$CoinUsageTransactionModelFromJson(json);
}
