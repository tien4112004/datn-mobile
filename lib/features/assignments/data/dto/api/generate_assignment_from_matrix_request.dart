import 'package:AIPrimary/features/assignments/data/dto/api/api_matrix_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generate_assignment_from_matrix_request.g.dart';

/// Request body for POST /assignments/generate-from-matrix.
@JsonSerializable(includeIfNull: false)
class GenerateAssignmentFromMatrixRequest {
  final String? matrixId;
  final ApiMatrixDto? matrix;
  final String subject;
  final String title;
  final String? description;
  final String? missingStrategy;
  final bool? includePersonalQuestions;
  final String? provider;
  final String? model;

  const GenerateAssignmentFromMatrixRequest({
    this.matrixId,
    this.matrix,
    required this.subject,
    required this.title,
    this.description,
    this.missingStrategy,
    this.includePersonalQuestions,
    this.provider,
    this.model,
  });

  factory GenerateAssignmentFromMatrixRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$GenerateAssignmentFromMatrixRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GenerateAssignmentFromMatrixRequestToJson(this);
}
