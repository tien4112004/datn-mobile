import 'package:json_annotation/json_annotation.dart';

part 'publish_request_dto.g.dart';

@JsonSerializable()
class PublishRequestDto {
  final String? id;
  final String? questionId;
  final String? requesterId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PublishRequestDto({
    this.id,
    this.questionId,
    this.requesterId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PublishRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PublishRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PublishRequestDtoToJson(this);
}
