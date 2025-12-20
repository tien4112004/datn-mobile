import 'package:json_annotation/json_annotation.dart';

part 'art_style_dto.g.dart';

@JsonSerializable()
class ArtStyleDto {
  final String id;
  final String name;

  @JsonKey(name: 'labelKey')
  final String labelKey;

  final String? visual;
  final String? modifiers;

  @JsonKey(name: 'isEnabled')
  final bool isEnabled;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  final Map<String, dynamic>? data;

  const ArtStyleDto({
    required this.id,
    required this.name,
    required this.labelKey,
    this.visual,
    this.modifiers,
    this.isEnabled = true,
    this.createdAt,
    this.updatedAt,
    this.data,
  });

  factory ArtStyleDto.fromJson(Map<String, dynamic> json) =>
      _$ArtStyleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ArtStyleDtoToJson(this);
}
