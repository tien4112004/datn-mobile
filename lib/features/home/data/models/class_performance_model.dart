import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:AIPrimary/features/home/data/models/at_risk_student_model.dart';

part 'class_performance_model.freezed.dart';
part 'class_performance_model.g.dart';

@freezed
abstract class ClassPerformanceModel with _$ClassPerformanceModel {
  const factory ClassPerformanceModel({
    required String classId,
    required String className,
    required int totalStudents,
    required int activeStudents,
    required double participationRate,
    required double averageScore,
    required Map<String, int> gradeDistribution,
    required List<AtRiskStudentModel> atRiskStudents,
    required List<AssignmentSummaryModel> recentAssignments,
    required EngagementMetrics engagement,
  }) = _ClassPerformanceModel;

  factory ClassPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$ClassPerformanceModelFromJson(json);
}

@freezed
abstract class AssignmentSummaryModel with _$AssignmentSummaryModel {
  const factory AssignmentSummaryModel({
    required String assignmentId,
    required String title,
    required DateTime dueDate,
    required int totalSubmissions,
    required int gradedSubmissions,
    required double averageScore,
    required double participationRate,
  }) = _AssignmentSummaryModel;

  factory AssignmentSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentSummaryModelFromJson(json);
}

@freezed
abstract class EngagementMetrics with _$EngagementMetrics {
  const factory EngagementMetrics({
    required double last24Hours,
    required double last7Days,
    required double avgSubmissionsPerStudent,
  }) = _EngagementMetrics;

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) =>
      _$EngagementMetricsFromJson(json);
}
