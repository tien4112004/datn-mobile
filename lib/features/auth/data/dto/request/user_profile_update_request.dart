import 'package:json_annotation/json_annotation.dart';

part 'user_profile_update_request.g.dart';

@JsonSerializable()
class UserProfileUpdateRequest {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? phoneNumber;

  UserProfileUpdateRequest({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.phoneNumber,
  });

  factory UserProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserProfileUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileUpdateRequestToJson(this);
}
