import 'package:datn_mobile/features/students/domain/entity/student.dart';
import 'package:datn_mobile/features/students/enum/student_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student_response_dto.g.dart';

@JsonSerializable()
class StudentResponseDto {
  final String id;
  final String userId;
  final String? address;
  final String? parentContactEmail;
  final String status;
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
    required this.status,
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
    status: StudentStatus.fromValue(status),
    createdAt: createdAt,
    updatedAt: updatedAt,
    username: username,
    firstName: firstName,
    lastName: lastName,
    avatarUrl: avatarUrl,
    phoneNumber: phoneNumber,
  );
}
