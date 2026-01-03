import 'package:datn_mobile/features/exams/data/dto/question_order_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_exam_request_dto.g.dart';

/// DTO for updating an exam.
/// Based on UpdateExamRequest schema from exams.yaml API.
@JsonSerializable()
class UpdateExamRequestDto {
  final String? title;
  final String? description;
  @JsonKey(name: 'time_limit_minutes')
  final int? timeLimitMinutes;
  @JsonKey(name: 'question_order')
  final QuestionOrderDto? questionOrder;

  UpdateExamRequestDto({
    this.title,
    this.description,
    this.timeLimitMinutes,
    this.questionOrder,
  });

  factory UpdateExamRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateExamRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateExamRequestDtoToJson(this);
}
