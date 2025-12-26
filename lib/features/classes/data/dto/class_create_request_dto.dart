import 'package:json_annotation/json_annotation.dart';

part 'class_create_request_dto.g.dart';

/// DTO for creating a new class.
/// Based on ClassCreateRequest schema from classes.yaml API.
@JsonSerializable()
class ClassCreateRequestDto {
  /// Class name (required, max 50 characters).
  final String name;

  /// Optional class description.
  final String? description;

  /// Optional class settings.
  final String? settings;

  ClassCreateRequestDto({required this.name, this.description, this.settings});

  factory ClassCreateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ClassCreateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClassCreateRequestDtoToJson(this);
}
