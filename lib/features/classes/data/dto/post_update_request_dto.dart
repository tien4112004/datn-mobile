import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/classes/data/dto/linked_resource_dto.dart';

part 'post_update_request_dto.g.dart';

/// Data Transfer Object for updating an existing post
@JsonSerializable(includeIfNull: false)
class PostUpdateRequestDto {
  final String? content;
  final String? type;
  final List<String>? attachments;
  final List<LinkedResourceDto>? linkedResources;
  final String? linkedLessonId;
  final bool? isPinned;
  final bool? allowComments;

  const PostUpdateRequestDto({
    this.content,
    this.type,
    this.attachments,
    this.linkedResources,
    this.linkedLessonId,
    this.isPinned,
    this.allowComments,
  });

  factory PostUpdateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PostUpdateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostUpdateRequestDtoToJson(this);
}
