import 'package:json_annotation/json_annotation.dart';

part 'user_profile_response.g.dart';

@JsonSerializable()
class UserProfileResponse {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? phoneNumber;
  final String? avatarUrl;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserProfileResponse(
    this.dateOfBirth,
    this.phoneNumber,
    this.avatarUrl, {
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);
}
