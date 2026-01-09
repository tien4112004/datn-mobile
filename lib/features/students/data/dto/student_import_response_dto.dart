import 'package:datn_mobile/features/students/data/dto/student_credential_dto.dart';
import 'package:datn_mobile/features/students/domain/entity/student_import_result.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student_import_response_dto.g.dart';

@JsonSerializable()
class StudentImportResponseDto {
  final bool success;
  final int studentsCreated;
  final String? message;
  final List<StudentCredentialDto>? credentials;
  final List<String>? errors;

  StudentImportResponseDto({
    required this.success,
    required this.studentsCreated,
    this.message,
    this.credentials,
    this.errors,
  });

  factory StudentImportResponseDto.fromJson(Map<String, dynamic> json) =>
      _$StudentImportResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentImportResponseDtoToJson(this);
}

extension StudentImportResponseMapper on StudentImportResponseDto {
  StudentImportResult toEntity() => StudentImportResult(
    success: success,
    studentsCreated: studentsCreated,
    message: message,
    credentials: credentials?.map((dto) => dto.toEntity()).toList() ?? [],
    errors: errors ?? [],
  );
}
