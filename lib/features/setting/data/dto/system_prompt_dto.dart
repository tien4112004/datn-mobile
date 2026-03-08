import 'package:json_annotation/json_annotation.dart';

part 'system_prompt_dto.g.dart';

@JsonSerializable()
class SystemPromptResponseDto {
  final String id;
  final String prompt;
  @JsonKey(name: 'active')
  final bool isActive;
  final String updatedAt;

  const SystemPromptResponseDto({
    required this.id,
    required this.prompt,
    required this.isActive,
    required this.updatedAt,
  });

  factory SystemPromptResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SystemPromptResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SystemPromptResponseDtoToJson(this);
}

@JsonSerializable()
class SystemPromptRequestDto {
  final String prompt;

  const SystemPromptRequestDto({required this.prompt});

  factory SystemPromptRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SystemPromptRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SystemPromptRequestDtoToJson(this);
}
