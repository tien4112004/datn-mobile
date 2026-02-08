import 'package:json_annotation/json_annotation.dart';

part 'example_prompt_dto.g.dart';

@JsonSerializable()
class ExamplePromptDto {
  final String id;
  final String prompt;
  final String icon;
  final String type;
  final String language;
  final String? data;

  const ExamplePromptDto({
    required this.id,
    required this.prompt,
    required this.icon,
    required this.type,
    required this.language,
    this.data,
  });

  factory ExamplePromptDto.fromJson(Map<String, dynamic> json) =>
      _$ExamplePromptDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamplePromptDtoToJson(this);
}
