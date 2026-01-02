import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_update_request_dto.g.dart';

/// Data transfer object for class update requests.
///
/// Maps to the ClassUpdateRequest schema in the API:
/// - name: Class name (max 50 characters)
/// - description: Optional description
/// - settings: Optional settings JSON string
/// - isActive: Active status flag
@JsonSerializable()
class ClassUpdateRequestDto {
  final String? name;
  final String? description;
  final String? settings;
  final bool? isActive;

  const ClassUpdateRequestDto({
    this.name,
    this.description,
    this.settings,
    this.isActive,
  });

  Map<String, dynamic> toJson(ClassUpdateRequestDto instance) =>
      _$ClassUpdateRequestDtoToJson(instance);

  factory ClassUpdateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ClassUpdateRequestDtoFromJson(json);
}
