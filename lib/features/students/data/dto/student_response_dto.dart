import 'package:AIPrimary/features/students/domain/entity/student.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student_response_dto.g.dart';

@JsonSerializable()
class StudentResponseDto {
  final String id;
  final String userId;
  final String? address;
  final String? parentContactEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? username;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? phoneNumber;

  StudentResponseDto({
    required this.id,
    required this.userId,
    this.address,
    this.parentContactEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.password,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.phoneNumber,
  });

  factory StudentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$StudentResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentResponseDtoToJson(this);
}

extension StudentResponseMapper on StudentResponseDto {
  Student toEntity() => Student(
    id: id,
    userId: userId,
    address: address,
    parentContactEmail: parentContactEmail,
    createdAt: createdAt,
    updatedAt: updatedAt,
    username: username,
    password: password,
    firstName: firstName,
    lastName: lastName,
    avatarUrl: avatarUrl,
    phoneNumber: phoneNumber,
  );
}
