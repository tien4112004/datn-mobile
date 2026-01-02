import 'package:json_annotation/json_annotation.dart';

part 'student_create_request_dto.g.dart';

DateTime? _dateFromJson(String? json) {
  if (json == null) return null;
  return DateTime.parse(json);
}

String? _dateToJson(DateTime? date) {
  if (date == null) return null;
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

@JsonSerializable()
class StudentCreateRequestDto {
  final String fullName;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String parentName;
  final String parentPhone;
  final String? parentContactEmail;
  final String classId;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? enrollmentDate;
  final String? status;

  StudentCreateRequestDto({
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    required this.parentName,
    required this.parentPhone,
    this.parentContactEmail,
    required this.classId,
    this.enrollmentDate,
    this.status,
  });

  factory StudentCreateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$StudentCreateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentCreateRequestDtoToJson(this);
}
