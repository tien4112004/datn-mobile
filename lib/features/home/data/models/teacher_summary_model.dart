import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_summary_model.freezed.dart';
part 'teacher_summary_model.g.dart';

@freezed
abstract class TeacherSummaryModel with _$TeacherSummaryModel {
  const factory TeacherSummaryModel({
    required int totalClasses,
    required int totalStudents,
    required int totalAssignments,
    required int pendingGrading,
    required double averageClassScore,
    required double engagementRate24h,
    required Map<String, int> overallGradeDistribution,
    @Default(0) int atRiskStudentsCount,
    ComparisonMetrics? comparison,
  }) = _TeacherSummaryModel;

  factory TeacherSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherSummaryModelFromJson(json);
}

@freezed
abstract class ComparisonMetrics with _$ComparisonMetrics {
  const factory ComparisonMetrics({
    double? scoreChange,
    double? engagementChange,
    double? submissionChange,
  }) = _ComparisonMetrics;

  factory ComparisonMetrics.fromJson(Map<String, dynamic> json) =>
      _$ComparisonMetricsFromJson(json);
}
