import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'class_response_dto.g.dart';

/// Teacher response dto.
@JsonSerializable()
class TeacherResponseDto {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  TeacherResponseDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory TeacherResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TeacherResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherResponseDtoToJson(this);

  String get fullName => '$firstName $lastName';
}

/// DTO for full class details.
/// Based on ClassResponseDto schema from classes.yaml API.
@JsonSerializable()
class ClassResponseDto {
  final String id;
  final TeacherResponseDto teacher;
  final String name;
  final String? description;
  final String? joinCode;
  final String? settings;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClassResponseDto({
    required this.id,
    required this.teacher,
    required this.name,
    this.description,
    this.joinCode,
    this.settings,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ClassResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ClassResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClassResponseDtoToJson(this);
}

/// Extension for mapping DTO to domain entity.
extension ClassResponseMapper on ClassResponseDto {
  ClassEntity toEntity() => ClassEntity(
    id: id,
    teacherId: teacher.id,
    teacherName: teacher.fullName,
    teacherEmail: teacher.email,
    name: name,
    description: description,
    joinCode: joinCode,
    // settings field is available in DTO but currently not mapped to Entity properties directly
    // apart from being available if needed.
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
