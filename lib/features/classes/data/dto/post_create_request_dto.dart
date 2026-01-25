import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/classes/data/dto/linked_resource_dto.dart';

part 'post_create_request_dto.g.dart';

/// Data Transfer Object for creating a new post
@JsonSerializable(includeIfNull: false)
class PostCreateRequestDto {
  final String content;
  final String type;
  final List<String>? attachments;
  final List<LinkedResourceDto>? linkedResources;
  final String? linkedLessonId;
  final DateTime? dueDate;
  final bool? allowComments;

  const PostCreateRequestDto({
    required this.content,
    required this.type,
    this.attachments,
    this.linkedResources,
    this.linkedLessonId,
    this.dueDate,
    this.allowComments,
  });

  factory PostCreateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PostCreateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostCreateRequestDtoToJson(this);
}
