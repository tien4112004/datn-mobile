import 'package:datn_mobile/features/auth/domain/entities/user_role.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String? email;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String phoneNumber;

  // User role - can be student or teacher
  @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
  final UserRole? role;

  UserProfile({
    required this.lastName,
    required this.firstName,
    required this.phoneNumber,
    this.email,
    this.dateOfBirth,
    this.role,
  });

  String get fullName => '$firstName $lastName';

  UserProfile copyWith({
    String? email,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? phoneNumber,
    UserRole? role,
  }) {
    return UserProfile(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }

  static UserRole? _roleFromJson(String? value) => UserRole.fromName(value);
  static String? _roleToJson(UserRole? role) => role?.value;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
