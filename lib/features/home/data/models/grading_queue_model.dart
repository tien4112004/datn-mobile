import 'package:freezed_annotation/freezed_annotation.dart';

part 'grading_queue_model.freezed.dart';
part 'grading_queue_model.g.dart';

@freezed
abstract class GradingQueueItemModel with _$GradingQueueItemModel {
  const factory GradingQueueItemModel({
    required String submissionId,
    String? assignmentId,
    required String assignmentTitle,
    required String postId,
    required String classId,
    required String className,
    required UserMinimalInfo student,
    required DateTime submittedAt,
    required int daysSinceSubmission,
    required String status,
    double? autoGradedScore,
    double? maxScore,
  }) = _GradingQueueItemModel;

  factory GradingQueueItemModel.fromJson(Map<String, dynamic> json) =>
      _$GradingQueueItemModelFromJson(json);
}

@freezed
abstract class UserMinimalInfo with _$UserMinimalInfo {
  const factory UserMinimalInfo({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? avatar,
  }) = _UserMinimalInfo;

  factory UserMinimalInfo.fromJson(Map<String, dynamic> json) =>
      _$UserMinimalInfoFromJson(json);
}
