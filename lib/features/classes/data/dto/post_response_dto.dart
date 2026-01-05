import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/classes/domain/entity/post_entity.dart';
import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';

part 'post_response_dto.g.dart';

/// Data Transfer Object for Post API responses
@JsonSerializable()
class PostResponseDto {
  final String id;
  final String classId;
  final String authorId;
  final String content;
  final String type;
  final List<String>? attachments;
  final List<String>? linkedResourceIds;
  final String? linkedLessonId;
  final bool isPinned;
  final bool allowComments;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostResponseDto({
    required this.id,
    required this.classId,
    required this.authorId,
    required this.content,
    required this.type,
    this.attachments,
    this.linkedResourceIds,
    this.linkedLessonId,
    required this.isPinned,
    required this.allowComments,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PostResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostResponseDtoToJson(this);
}

/// Extension to map PostResponseDto to domain entity
extension PostResponseMapper on PostResponseDto {
  PostEntity toEntity() => PostEntity(
    id: id,
    classId: classId,
    authorId: authorId,
    content: content,
    type: PostType.fromString(type),
    attachments: attachments ?? [],
    linkedResourceIds: linkedResourceIds ?? [],
    linkedLessonId: linkedLessonId,
    isPinned: isPinned,
    allowComments: allowComments,
    commentCount: commentCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
