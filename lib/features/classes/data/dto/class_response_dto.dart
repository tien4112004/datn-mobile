import 'package:datn_mobile/features/classes/domain/entity/class_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'class_response_dto.g.dart';

/// DTO for full class details.
/// Based on ClassResponseDto schema from classes.yaml API.
@JsonSerializable()
class ClassResponseDto {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? joinCode;
  final String? settings;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClassResponseDto({
    required this.id,
    required this.ownerId,
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
    ownerId: ownerId,
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
