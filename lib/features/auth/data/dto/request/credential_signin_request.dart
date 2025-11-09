import 'package:json_annotation/json_annotation.dart';

part 'credential_signin_request.g.dart';

@JsonSerializable()
class CredentialSigninRequest {
  final String username;
  final String password;

  CredentialSigninRequest({required this.username, required this.password});

  factory CredentialSigninRequest.fromJson(Map<String, dynamic> json) =>
      _$CredentialSigninRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialSigninRequestToJson(this);
}
