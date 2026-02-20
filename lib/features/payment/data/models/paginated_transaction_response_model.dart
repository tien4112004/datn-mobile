import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';

part 'paginated_transaction_response_model.freezed.dart';
part 'paginated_transaction_response_model.g.dart';

@freezed
abstract class PaginatedTransactionResponseModel
    with _$PaginatedTransactionResponseModel {
  const factory PaginatedTransactionResponseModel({
    required List<TransactionDetailsModel> data,
    required PaginationModel pagination,
  }) = _PaginatedTransactionResponseModel;

  factory PaginatedTransactionResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$PaginatedTransactionResponseModelFromJson(json);
}

@freezed
abstract class PaginationModel with _$PaginationModel {
  const factory PaginationModel({
    required int currentPage,
    required int pageSize,
    required int totalItems,
    required int totalPages,
  }) = _PaginationModel;

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);
}
