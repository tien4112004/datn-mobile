import 'package:AIPrimary/features/assignments/data/dto/api/api_matrix_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generate_full_assignment_request.g.dart';

/// Request body for POST /assignments/generate-full-assignment.
@JsonSerializable(includeIfNull: false)
class GenerateFullAssignmentRequest {
  final String? matrixId;
  final ApiMatrixDto? matrix;
  final String title;
  final String? description;
  final String? provider;
  final String? model;

  const GenerateFullAssignmentRequest({
    this.matrixId,
    this.matrix,
    required this.title,
    this.description,
    this.provider,
    this.model,
  });

  factory GenerateFullAssignmentRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateFullAssignmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateFullAssignmentRequestToJson(this);
}
