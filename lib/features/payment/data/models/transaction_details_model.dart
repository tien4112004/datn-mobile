import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_details_model.freezed.dart';
part 'transaction_details_model.g.dart';

@freezed
abstract class TransactionDetailsModel with _$TransactionDetailsModel {
  const factory TransactionDetailsModel({
    required String id,
    required double amount,
    String? description,
    String? referenceCode,
    required String status, // PENDING, SUCCESS, FAILED, CANCELLED
    String? gateway, // SEPAY, PAYOS
    int? coinsAwarded, // Coins awarded for successful transaction
    String? errorMessage, // Error message for failed transactions
    required DateTime createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) = _TransactionDetailsModel;

  factory TransactionDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionDetailsModelFromJson(json);
}
