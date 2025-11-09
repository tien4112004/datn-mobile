import 'package:json_annotation/json_annotation.dart';

part 'token_exchange_request.g.dart';

@JsonSerializable()
class TokenExchangeRequest {
  final String code;
  final String redirectUri;
  final String state;

  TokenExchangeRequest({
    required this.code,
    required this.redirectUri,
    required this.state,
  });

  factory TokenExchangeRequest.fromJson(Map<String, dynamic> json) =>
      _$TokenExchangeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TokenExchangeRequestToJson(this);
}
