import 'package:datn_mobile/features/students/domain/entity/student_credential.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student_credential_dto.g.dart';

@JsonSerializable()
class StudentCredentialDto {
  final String studentId;
  final String username;
  final String password;
  final String email;
  final String fullName;

  StudentCredentialDto({
    required this.studentId,
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
  });

  factory StudentCredentialDto.fromJson(Map<String, dynamic> json) =>
      _$StudentCredentialDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentCredentialDtoToJson(this);
}

extension StudentCredentialMapper on StudentCredentialDto {
  StudentCredential toEntity() => StudentCredential(
    studentId: studentId,
    username: username,
    password: password,
    email: email,
    fullName: fullName,
  );
}
