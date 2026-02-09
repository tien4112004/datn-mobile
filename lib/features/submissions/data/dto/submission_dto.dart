import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/submissions/data/dto/answer_data_dto.dart';
import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';
import 'package:AIPrimary/features/submissions/domain/entity/answer_entity.dart';

part 'submission_dto.g.dart';

/// Request DTO for creating a submission
@JsonSerializable(explicitToJson: true)
class CreateSubmissionRequestDto {
  final String studentId;
  final String postId;
  final List<AnswerDataDto> questions;

  const CreateSubmissionRequestDto({
    required this.studentId,
    required this.postId,
    required this.questions,
  });

  factory CreateSubmissionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateSubmissionRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSubmissionRequestDtoToJson(this);
}

/// Extension to create request from answer entities
extension CreateSubmissionRequest on List<AnswerEntity> {
  CreateSubmissionRequestDto toCreateRequest(String studentId, String postId) {
    return CreateSubmissionRequestDto(
      studentId: studentId,
      postId: postId,
      questions: map((answer) => answer.toDto()).toList(),
    );
  }
}

/// Validate Submission
@JsonSerializable(explicitToJson: true)
class ValidateSubmissionRequestDto {
  final String studentId;
  final List<AnswerDataDto> answers;

  const ValidateSubmissionRequestDto({
    required this.studentId,
    required this.answers,
  });

  factory ValidateSubmissionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ValidateSubmissionRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ValidateSubmissionRequestDtoToJson(this);
}

/// Response DTO for submission
@JsonSerializable(explicitToJson: true)
class SubmissionResponseDto {
  final String id;
  final String assignmentId;
  final String postId;
  final String studentId;
  final StudentDto student;
  @JsonKey(name: 'questions')
  final List<AnswerResponseDto> answers;
  final String status;
  final double? score;
  final double maxScore;
  final String? overallFeedback;
  final String submittedAt; // ISO 8601 string
  final String? gradedAt; // ISO 8601 string

  const SubmissionResponseDto({
    required this.id,
    required this.assignmentId,
    required this.postId,
    required this.studentId,
    required this.student,
    required this.answers,
    required this.status,
    this.score,
    required this.maxScore,
    this.overallFeedback,
    required this.submittedAt,
    this.gradedAt,
  });

  factory SubmissionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubmissionResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SubmissionResponseDtoToJson(this);
}

@JsonSerializable()
class StudentDto {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  const StudentDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory StudentDto.fromJson(Map<String, dynamic> json) =>
      _$StudentDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StudentDtoToJson(this);
}

extension StudentDtoToEntity on StudentDto {
  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }
}

/// Extension to convert response DTO to entity
extension SubmissionResponseDtoToEntity on SubmissionResponseDto {
  SubmissionEntity toEntity() {
    return SubmissionEntity(
      id: id,
      assignmentId: assignmentId,
      postId: postId,
      studentId: studentId,
      student: student.toEntity(),
      questions: answers.map((a) => a.toEntity()).toList(),
      status: SubmissionStatus.fromValue(status),
      score: score,
      maxScore: maxScore,
      overallFeedback: overallFeedback,
      submittedAt: DateTime.parse(submittedAt),
      gradedAt: gradedAt != null ? DateTime.parse(gradedAt!) : null,
    );
  }
}

/// Request DTO for grading a submission
@JsonSerializable()
class GradeSubmissionRequestDto {
  final Map<String, double> questionScores;
  final Map<String, String>? questionFeedback;
  final String? overallFeedback;

  const GradeSubmissionRequestDto({
    required this.questionScores,
    this.questionFeedback,
    this.overallFeedback,
  });

  factory GradeSubmissionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GradeSubmissionRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GradeSubmissionRequestDtoToJson(this);
}

/// Validation response DTO
@JsonSerializable()
class ValidationResponseDto {
  final bool valid;
  final String? reason;
  final int? attemptsRemaining;

  const ValidationResponseDto({
    required this.valid,
    this.reason,
    this.attemptsRemaining,
  });

  factory ValidationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ValidationResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ValidationResponseDtoToJson(this);
}

/// Validation result entity
class ValidationResult {
  final bool canSubmit;
  final String? reason;
  final int? attemptsRemaining;

  const ValidationResult({
    required this.canSubmit,
    this.reason,
    this.attemptsRemaining,
  });
}

/// Extension to convert validation DTO to entity
extension ValidationResponseDtoToEntity on ValidationResponseDto {
  ValidationResult toEntity() {
    return ValidationResult(
      canSubmit: valid,
      reason: reason,
      attemptsRemaining: attemptsRemaining,
    );
  }
}
