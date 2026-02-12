import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:AIPrimary/features/home/data/models/grading_queue_model.dart';

part 'recent_activity_model.freezed.dart';
part 'recent_activity_model.g.dart';

enum ActivityType {
  @JsonValue('SUBMISSION')
  submission,
  @JsonValue('GRADING_COMPLETED')
  gradingCompleted,
  @JsonValue('LATE_SUBMISSION')
  lateSubmission,
  @JsonValue('RESUBMISSION')
  resubmission,
}

@freezed
abstract class RecentActivityModel with _$RecentActivityModel {
  const factory RecentActivityModel({
    required String id,
    required ActivityType type,
    required UserMinimalInfo student,
    required String assignmentTitle,
    required String assignmentId,
    required String className,
    required String classId,
    required DateTime timestamp,
    double? score,
    required String status,
  }) = _RecentActivityModel;

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityModelFromJson(json);
}
