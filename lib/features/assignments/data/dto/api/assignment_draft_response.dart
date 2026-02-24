import 'package:AIPrimary/features/assignments/data/dto/api/question_response.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_draft_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assignment_draft_response.g.dart';

/// DTO for a single gap entry in the draft response.
@JsonSerializable()
class MatrixGapResponseDto {
  final String topic;
  final String difficulty;
  final String questionType;
  final int requiredCount;
  final int availableCount;

  const MatrixGapResponseDto({
    required this.topic,
    required this.difficulty,
    required this.questionType,
    required this.requiredCount,
    required this.availableCount,
  });

  factory MatrixGapResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MatrixGapResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MatrixGapResponseDtoToJson(this);
}

/// DTO for the AssignmentDraftDto returned by generation endpoints.
@JsonSerializable(fieldRename: FieldRename.none)
class AssignmentDraftResponse {
  final String id;
  final String title;
  final String ownerId;
  final String subject;
  final String? description;
  final String? grade;
  final List<QuestionResponse>? questions;
  final List<MatrixGapResponseDto>? missingQuestions;
  final double? totalPoints;
  final int? totalQuestions;
  final bool? isComplete;

  const AssignmentDraftResponse({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.subject,
    this.description,
    this.grade,
    this.questions,
    this.missingQuestions,
    this.totalPoints,
    this.isComplete,
    this.totalQuestions,
  });

  factory AssignmentDraftResponse.fromJson(Map<String, dynamic> json) =>
      _$AssignmentDraftResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentDraftResponseToJson(this);

  AssignmentDraftEntity toEntity() {
    final questionEntities =
        questions?.map((q) => q.toEntity()).toList() ?? [];
    final gapEntities = missingQuestions
            ?.map(
              (g) => MatrixGapEntity(
                topic: g.topic,
                difficulty: g.difficulty,
                questionType: g.questionType,
                requiredCount: g.requiredCount,
                availableCount: g.availableCount,
              ),
            )
            .toList() ??
        [];

    final computedTotal = questionEntities.fold<double>(
      0,
      (sum, q) => sum + q.points,
    );

    return AssignmentDraftEntity(
      id: id,
      title: title,
      description: description,
      subject: subject,
      grade: grade,
      questions: questionEntities,
      gaps: gapEntities,
      totalPoints: totalPoints ?? computedTotal,
      totalQuestions: totalQuestions ?? questionEntities.length,
      isComplete: isComplete ?? gapEntities.isEmpty,
    );
  }
}
