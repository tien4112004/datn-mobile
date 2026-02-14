import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:AIPrimary/features/home/data/models/grading_queue_model.dart';

part 'at_risk_student_model.freezed.dart';
part 'at_risk_student_model.g.dart';

enum RiskLevel {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('CRITICAL')
  critical,
}

@freezed
abstract class AtRiskStudentModel with _$AtRiskStudentModel {
  const factory AtRiskStudentModel({
    required UserMinimalInfo student,
    required double averageScore,
    required int missedSubmissions,
    required int lateSubmissions,
    required int totalAssignments,
    required RiskLevel riskLevel,
  }) = _AtRiskStudentModel;

  factory AtRiskStudentModel.fromJson(Map<String, dynamic> json) =>
      _$AtRiskStudentModelFromJson(json);
}
