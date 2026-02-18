import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/api_matrix_dto.dart';
import 'package:AIPrimary/features/assignments/domain/entity/matrix_template_entity.dart';

part 'matrix_template_response.g.dart';

/// API response DTO for matrix template from backend.
/// Matches MatrixTemplateResponseDto structure from Java backend.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class MatrixTemplateResponse {
  /// Unique template ID
  final String id;

  /// Owner user ID (null = public template, non-null = personal template)
  final String? ownerId;

  /// Template name
  final String name;

  /// Subject code (e.g., 'T' for Math, 'TV' for Vietnamese)
  final String subject;

  /// Grade level (e.g., '1', '2', '3', etc.)
  final String grade;

  /// ISO 8601 creation timestamp
  final String createdAt;

  /// ISO 8601 update timestamp
  final String updatedAt;

  /// Full 3D matrix structure with dimensions and cell values
  final ApiMatrixDto matrix;

  /// Total number of questions across all matrix cells
  final int totalQuestions;

  /// Total number of topics in the matrix
  final int totalTopics;

  const MatrixTemplateResponse({
    required this.id,
    this.ownerId,
    required this.name,
    required this.subject,
    required this.grade,
    required this.createdAt,
    required this.updatedAt,
    required this.matrix,
    required this.totalQuestions,
    required this.totalTopics,
  });

  factory MatrixTemplateResponse.fromJson(Map<String, dynamic> json) =>
      _$MatrixTemplateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MatrixTemplateResponseToJson(this);
}

/// Extension for mapping DTO to domain entity
extension MatrixTemplateResponseMapper on MatrixTemplateResponse {
  /// Converts API response DTO to domain entity
  MatrixTemplateEntity toEntity() {
    return MatrixTemplateEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      subject: subject,
      grade: grade,
      createdAt: DateTime.tryParse(createdAt),
      updatedAt: DateTime.tryParse(updatedAt),
      matrix: matrix.toEntity(),
      totalQuestions: totalQuestions,
      totalTopics: totalTopics,
    );
  }
}
