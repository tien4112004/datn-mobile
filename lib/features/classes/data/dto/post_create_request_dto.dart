import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/classes/data/dto/linked_resource_dto.dart';

part 'post_create_request_dto.g.dart';

/// Data Transfer Object for creating a new post
@JsonSerializable(includeIfNull: false)
class PostCreateRequestDto {
  final String content;
  final String type;
  final List<String>? attachments;
  final List<LinkedResourceDto>? linkedResources;
  final String? linkedLessonId;
  final String? assignmentId;
  final DateTime? dueDate;
  final bool? allowComments;

  // Assignment settings (only for Homework type posts)
  final int? maxSubmissions;
  final bool? allowRetake;
  final bool? showCorrectAnswers;
  final bool? showScoreImmediately;
  final double? passingScore;
  final DateTime? availableFrom;
  final DateTime? availableUntil;

  const PostCreateRequestDto({
    required this.content,
    required this.type,
    this.attachments,
    this.linkedResources,
    this.linkedLessonId,
    this.assignmentId,
    this.dueDate,
    this.allowComments,
    this.maxSubmissions,
    this.allowRetake,
    this.showCorrectAnswers,
    this.showScoreImmediately,
    this.passingScore,
    this.availableFrom,
    this.availableUntil,
  });

  factory PostCreateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PostCreateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostCreateRequestDtoToJson(this);
}
