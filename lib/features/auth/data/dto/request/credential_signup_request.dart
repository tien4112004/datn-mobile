import 'package:json_annotation/json_annotation.dart';

part 'credential_signup_request.g.dart';

@JsonSerializable()
class CredentialSignupRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime dateOfBirth;
  final String? phoneNumber;

  CredentialSignupRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.phoneNumber,
  });

  factory CredentialSignupRequest.fromJson(Map<String, dynamic> json) =>
      _$CredentialSignupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialSignupRequestToJson(this);
}

// Helper functions to convert DateTime to/from ISO 8601 date-only format (YYYY-MM-DD)
DateTime _dateFromJson(String? json) {
  if (json == null) {
    throw ArgumentError('dateOfBirth cannot be null');
  }
  return DateTime.parse(json);
}

String _dateToJson(DateTime date) {
  // Format as YYYY-MM-DD (date only, no time)
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
