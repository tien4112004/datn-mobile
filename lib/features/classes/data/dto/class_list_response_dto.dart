import 'package:datn_mobile/features/classes/domain/entity/class_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'class_list_response_dto.g.dart';

/// DTO for mapping class list API response.
/// Based on ClassListResponseDto schema from classes.yaml API.
@JsonSerializable()
class ClassListResponseDto {
  final String id;
  final String ownerId;
  final String name;
  final String? joinCode;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClassListResponseDto({
    required this.id,
    required this.ownerId,
    required this.name,
    this.joinCode,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ClassListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ClassListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClassListResponseDtoToJson(this);
}

/// Extension for mapping DTO to domain entity.
extension ClassListResponseMapper on ClassListResponseDto {
  ClassEntity toEntity() => ClassEntity(
    id: id,
    ownerId: ownerId,
    name: name,
    joinCode: joinCode,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
