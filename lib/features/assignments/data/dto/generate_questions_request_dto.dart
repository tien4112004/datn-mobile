import 'package:datn_mobile/features/assignments/data/dto/matrix_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generate_questions_request_dto.g.dart';

/// DTO for generating questions from matrix.
/// Based on GenerateQuestionsRequest schema from assignments.yaml API.
@JsonSerializable()
class GenerateQuestionsRequestDto {
  final List<MatrixItemDto> matrix;

  GenerateQuestionsRequestDto({required this.matrix});

  factory GenerateQuestionsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GenerateQuestionsRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateQuestionsRequestDtoToJson(this);
}
