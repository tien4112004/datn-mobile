import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/payment/data/models/coin_package_model.dart';

part 'coin_package_api_dto.g.dart';

/// API-layer DTO that mirrors the backend CoinPackageDto response.
/// Maps to [CoinPackageModel] via [toModel].
@JsonSerializable()
class CoinPackageApiDto {
  final String id;
  final String name;
  final int price;
  final int coin;
  final int? bonus;

  const CoinPackageApiDto({
    required this.id,
    required this.name,
    required this.price,
    required this.coin,
    this.bonus,
  });

  factory CoinPackageApiDto.fromJson(Map<String, dynamic> json) =>
      _$CoinPackageApiDtoFromJson(json);

  CoinPackageModel toModel() => CoinPackageModel(
    id: id,
    name: name, // raw backend name (e.g. "BASIC_20K"); localized in provider
    coins: coin,
    price: price,
    bonusCoins: (bonus != null && bonus! > 0) ? bonus : null,
  );
}
