import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String email;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String phoneNumber;

  // NOTE: This role is ONLY FOR STUDENT
  // Mean that the value of this field, if not null, is always 'STUDENT'
  final String? role;

  UserProfile({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phoneNumber,
    this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  String get fullName => "$firstName $lastName";
}
