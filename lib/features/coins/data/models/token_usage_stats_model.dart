import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_usage_stats_model.freezed.dart';
part 'token_usage_stats_model.g.dart';

@freezed
abstract class TokenUsageStatsModel with _$TokenUsageStatsModel {
  const factory TokenUsageStatsModel({
    int? totalTokens,
    required int totalRequests,
    String? model,
    String? requestType,
    String? totalCoin,
    String? totalMoney,
  }) = _TokenUsageStatsModel;

  factory TokenUsageStatsModel.fromJson(Map<String, dynamic> json) =>
      _$TokenUsageStatsModelFromJson(json);
}
