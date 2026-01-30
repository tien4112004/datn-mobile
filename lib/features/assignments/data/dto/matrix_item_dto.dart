import 'package:AIPrimary/features/assignments/domain/entity/matrix_item_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'matrix_item_dto.g.dart';

/// DTO for assignment matrix item.
/// Based on MatrixItem schema from assignments.yaml API.
@JsonSerializable()
class MatrixItemDto {
  final String topic;
  @JsonKey(name: 'question_type')
  final String questionType;
  final int count;
  @JsonKey(name: 'points_each')
  final int pointsEach;
  final String difficulty;
  @JsonKey(name: 'requires_context')
  final bool requiresContext;
  @JsonKey(name: 'context_type')
  final String? contextType;

  MatrixItemDto({
    required this.topic,
    required this.questionType,
    required this.count,
    required this.pointsEach,
    required this.difficulty,
    required this.requiresContext,
    this.contextType,
  });

  factory MatrixItemDto.fromJson(Map<String, dynamic> json) =>
      _$MatrixItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MatrixItemDtoToJson(this);
}

/// Extension for mapping DTO to domain entity.
extension MatrixItemMapper on MatrixItemDto {
  MatrixItemEntity toEntity() => MatrixItemEntity(
    topic: topic,
    questionType: QuestionType.fromApiValue(questionType),
    count: count,
    pointsEach: pointsEach,
    difficulty: Difficulty.fromApiValue(difficulty),
    requiresContext: requiresContext,
    contextType: contextType != null
        ? ContextType.fromApiValue(contextType!)
        : null,
  );

  static MatrixItemDto fromEntity(MatrixItemEntity entity) => MatrixItemDto(
    topic: entity.topic,
    questionType: entity.questionType.apiValue,
    count: entity.count,
    pointsEach: entity.pointsEach,
    difficulty: entity.difficulty.name,
    requiresContext: entity.requiresContext,
    contextType: entity.contextType?.apiValue,
  );
}
