import 'package:freezed_annotation/freezed_annotation.dart';

part 'coin_package_model.freezed.dart';

/// Client-side model for predefined coin packages
@freezed
abstract class CoinPackageModel with _$CoinPackageModel {
  const factory CoinPackageModel({
    required String id,
    required String name,
    required int coins,
    required int price, // in VND
    int? bonusCoins,
    bool? isPopular,
    String? description,
  }) = _CoinPackageModel;
}
