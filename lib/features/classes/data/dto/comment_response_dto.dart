import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/classes/domain/entity/comment_entity.dart';

part 'comment_response_dto.g.dart';

/// User information within a comment
@JsonSerializable()
class CommentUserDto {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  const CommentUserDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory CommentUserDto.fromJson(Map<String, dynamic> json) =>
      _$CommentUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommentUserDtoToJson(this);

  String get fullName => '$firstName $lastName'.trim();
}

/// Data Transfer Object for Comment API responses
@JsonSerializable()
class CommentResponseDto {
  final String id;
  final String postId;
  final String userId;
  final CommentUserDto? user;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CommentResponseDto({
    required this.id,
    required this.postId,
    required this.userId,
    this.user,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory CommentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CommentResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommentResponseDtoToJson(this);
}

/// Extension to map CommentResponseDto to domain entity
extension CommentResponseMapper on CommentResponseDto {
  CommentEntity toEntity() => CommentEntity(
    id: id,
    postId: postId,
    userId: userId,
    content: content,
    createdAt: createdAt,
    updatedAt: updatedAt,
    authorName: user?.fullName,
    authorEmail: user?.email,
  );
}
