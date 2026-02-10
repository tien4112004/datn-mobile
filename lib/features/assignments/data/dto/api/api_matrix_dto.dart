import 'package:AIPrimary/features/assignments/domain/entity/api_matrix_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_matrix_dto.g.dart';

/// DTO for a subtopic within a topic group.
@JsonSerializable()
class MatrixSubtopicDto {
  final String id;
  final String name;

  const MatrixSubtopicDto({required this.id, required this.name});

  factory MatrixSubtopicDto.fromJson(Map<String, dynamic> json) =>
      _$MatrixSubtopicDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MatrixSubtopicDtoToJson(this);
}

/// DTO for a topic group containing subtopics.
@JsonSerializable()
class MatrixDimensionTopicDto {
  final String name;
  final List<MatrixSubtopicDto> subtopics;

  const MatrixDimensionTopicDto({required this.name, required this.subtopics});

  factory MatrixDimensionTopicDto.fromJson(Map<String, dynamic> json) =>
      _$MatrixDimensionTopicDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MatrixDimensionTopicDtoToJson(this);
}

/// DTO for matrix dimensions (axes).
@JsonSerializable()
class MatrixDimensionsDto {
  final List<MatrixDimensionTopicDto> topics;
  final List<String> difficulties;
  final List<String> questionTypes;

  const MatrixDimensionsDto({
    required this.topics,
    required this.difficulties,
    required this.questionTypes,
  });

  factory MatrixDimensionsDto.fromJson(Map<String, dynamic> json) =>
      _$MatrixDimensionsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MatrixDimensionsDtoToJson(this);
}

/// DTO for the full API matrix (JSONB column).
@JsonSerializable()
class ApiMatrixDto {
  final String? grade;
  final String? subject;
  final MatrixDimensionsDto dimensions;
  final List<List<List<String>>> matrix;
  final int totalQuestions;
  final int totalPoints;

  const ApiMatrixDto({
    this.grade,
    this.subject,
    required this.dimensions,
    required this.matrix,
    required this.totalQuestions,
    required this.totalPoints,
  });

  factory ApiMatrixDto.fromJson(Map<String, dynamic> json) =>
      _$ApiMatrixDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ApiMatrixDtoToJson(this);
}

/// Extension for mapping domain entities back to DTOs.
extension ApiMatrixEntityMapper on ApiMatrixEntity {
  ApiMatrixDto toDto() => ApiMatrixDto(
    grade: grade,
    subject: subject,
    dimensions: MatrixDimensionsDto(
      topics: dimensions.topics
          .map(
            (t) => MatrixDimensionTopicDto(
              name: t.name,
              subtopics: t.subtopics
                  .map((s) => MatrixSubtopicDto(id: s.id, name: s.name))
                  .toList(),
            ),
          )
          .toList(),
      difficulties: dimensions.difficulties,
      questionTypes: dimensions.questionTypes,
    ),
    matrix: matrix,
    totalQuestions: totalQuestions,
    totalPoints: totalPoints,
  );
}

/// Extension for mapping DTOs to domain entities.
extension ApiMatrixDtoMapper on ApiMatrixDto {
  ApiMatrixEntity toEntity() => ApiMatrixEntity(
    grade: grade,
    subject: subject,
    dimensions: MatrixDimensions(
      topics: dimensions.topics
          .map(
            (t) => MatrixDimensionTopic(
              name: t.name,
              subtopics: t.subtopics
                  .map((s) => MatrixSubtopic(id: s.id, name: s.name))
                  .toList(),
            ),
          )
          .toList(),
      difficulties: dimensions.difficulties,
      questionTypes: dimensions.questionTypes,
    ),
    matrix: matrix,
    totalQuestions: totalQuestions,
    totalPoints: totalPoints,
  );
}
