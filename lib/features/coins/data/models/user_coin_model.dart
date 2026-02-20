import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_coin_model.freezed.dart';
part 'user_coin_model.g.dart';

@freezed
abstract class UserCoinModel with _$UserCoinModel {
  const factory UserCoinModel({required String id, required int coin}) =
      _UserCoinModel;

  factory UserCoinModel.fromJson(Map<String, dynamic> json) =>
      _$UserCoinModelFromJson(json);
}
