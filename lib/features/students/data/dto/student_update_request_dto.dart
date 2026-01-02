import 'package:json_annotation/json_annotation.dart';

part 'student_update_request_dto.g.dart';

DateTime? _dateFromJson(String? json) {
  if (json == null) return null;
  return DateTime.parse(json);
}

String? _dateToJson(DateTime? date) {
  if (date == null) return null;
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

@JsonSerializable()
class StudentUpdateRequestDto {
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? enrollmentDate;
  final String? address;
  final String? parentContactEmail;
  final String? status;

  StudentUpdateRequestDto({
    this.enrollmentDate,
    this.address,
    this.parentContactEmail,
    this.status,
  });

  factory StudentUpdateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$StudentUpdateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentUpdateRequestDtoToJson(this);
}
