import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_entity.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/classes/data/dto/linked_resource_dto.dart';

part 'post_response_dto.g.dart';

/// Author response dto
@JsonSerializable()
class AuthorResponseDto {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;

  const AuthorResponseDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
  });

  factory AuthorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthorResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorResponseDtoToJson(this);

  String get fullName => '$firstName $lastName';
}

/// Data Transfer Object for Post API responses
@JsonSerializable()
class PostResponseDto {
  final String id;
  final String classId;
  final AuthorResponseDto author;
  final String content;
  final String type;
  final List<String>? attachments;
  final List<LinkedResourceDto>? linkedResources;
  final String? assignmentId;
  final DateTime? dueDate;
  final bool isPinned;
  final bool allowComments;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostResponseDto({
    required this.id,
    required this.classId,
    required this.author,
    required this.content,
    required this.type,
    this.attachments,
    this.linkedResources,
    this.assignmentId,
    this.dueDate,
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
    authorId: author.id,
    authorName: author.fullName,
    authorEmail: author.email,
    authorAvatarUrl: author.avatarUrl,
    content: content,
    type: PostType.fromName(type),
    attachments: attachments ?? [],
    linkedResources:
        linkedResources?.map((dto) => dto.toEntity()).toList() ?? [],
    assignmentId: assignmentId,
    dueDate: dueDate,
    isPinned: isPinned,
    allowComments: allowComments,
    commentCount: commentCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
