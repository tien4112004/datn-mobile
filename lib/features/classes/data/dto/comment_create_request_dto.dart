import 'package:json_annotation/json_annotation.dart';

part 'comment_create_request_dto.g.dart';

/// Data Transfer Object for creating a new comment
@JsonSerializable()
class CommentCreateRequestDto {
  final String content;

  const CommentCreateRequestDto({required this.content});

  factory CommentCreateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CommentCreateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommentCreateRequestDtoToJson(this);
}
