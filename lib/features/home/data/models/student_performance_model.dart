import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_performance_model.freezed.dart';
part 'student_performance_model.g.dart';

@freezed
abstract class StudentPerformanceModel with _$StudentPerformanceModel {
  const factory StudentPerformanceModel({
    required double overallAverage,
    required int completedAssignments,
    required int totalAssignments,
    required double completionRate,
    required int pendingAssignments,
    required int overdueAssignments,
    required List<ClassSummary> classSummaries,
    required List<PerformanceTrend> performanceTrends,
    required Map<String, int> gradeDistribution,
  }) = _StudentPerformanceModel;

  factory StudentPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$StudentPerformanceModelFromJson(json);
}

@freezed
abstract class ClassSummary with _$ClassSummary {
  const factory ClassSummary({
    required String className,
    required double averageScore,
    required int completedAssignments,
    required int totalAssignments,
    required double completionRate,
  }) = _ClassSummary;

  factory ClassSummary.fromJson(Map<String, dynamic> json) =>
      _$ClassSummaryFromJson(json);
}

@freezed
abstract class PerformanceTrend with _$PerformanceTrend {
  const factory PerformanceTrend({
    required String period,
    required double averageScore,
    required int submissionCount,
  }) = _PerformanceTrend;

  factory PerformanceTrend.fromJson(Map<String, dynamic> json) =>
      _$PerformanceTrendFromJson(json);
}
