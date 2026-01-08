import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/classes/domain/entity/comment_entity.dart';

part 'comment_response_dto.g.dart';

/// Data Transfer Object for Comment API responses
@JsonSerializable()
class CommentResponseDto {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CommentResponseDto({
    required this.id,
    required this.postId,
    required this.userId,
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
  );
}
