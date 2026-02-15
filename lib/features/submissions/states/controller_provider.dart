import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/submissions/data/dto/submission_dto.dart';
import 'package:AIPrimary/features/submissions/domain/entity/answer_entity.dart';
import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';
import 'package:AIPrimary/features/submissions/domain/entity/statistics_entity.dart';
import 'package:AIPrimary/features/submissions/states/repository_provider.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

part 'answer_collection_controller.dart';
part 'create_submission_controller.dart';
part 'student_submissions_controller.dart';
part 'post_submissions_controller.dart';
part 'submission_detail_controller.dart';
part 'grade_submission_controller.dart';
part 'validation_controller.dart';
part 'submission_statistics_controller.dart';

// ============ Provider Definitions ============

/// Provider for answer collection (used during "doing" flow)
/// Family with AssignmentEntity to initialize answers
final answerCollectionProvider =
    StateNotifierProvider.family<
      AnswerCollectionController,
      AnswerCollectionState,
      AssignmentEntity
    >((ref, assignment) {
      return AnswerCollectionController(assignment);
    });

/// Provider for creating a submission
final createSubmissionControllerProvider =
    AsyncNotifierProvider<CreateSubmissionController, SubmissionEntity?>(
      () => CreateSubmissionController(),
    );

/// Provider for fetching student's own submissions
/// Parameters: { assignmentId, studentId }
final studentSubmissionsProvider =
    AsyncNotifierProvider.family<
      StudentSubmissionsController,
      List<SubmissionEntity>,
      StudentSubmissionsParams
    >((params) => StudentSubmissionsController(params: params));

/// Provider for fetching all submissions for a post (teacher view)
final postSubmissionsProvider =
    AsyncNotifierProvider.family<
      PostSubmissionsController,
      List<SubmissionEntity>,
      String
    >((postId) => PostSubmissionsController(postId: postId));

/// Provider for fetching a single submission detail
final submissionDetailProvider =
    AsyncNotifierProvider.family<
      SubmissionDetailController,
      SubmissionEntity,
      String
    >((submissionId) => SubmissionDetailController(submissionId: submissionId));

/// Provider for grading a submission
final gradeSubmissionControllerProvider =
    AsyncNotifierProvider<GradeSubmissionController, void>(
      () => GradeSubmissionController(),
    );

/// Provider for validating if student can submit
final validationProvider =
    AsyncNotifierProvider.family<
      ValidationController,
      ValidationResult?,
      ValidationParams
    >((params) => ValidationController(params: params));

/// Provider for submission statistics (teacher view)
final submissionStatisticsProvider =
    AsyncNotifierProvider.family<
      SubmissionStatisticsController,
      SubmissionStatisticsEntity,
      String
    >((postId) => SubmissionStatisticsController(postId: postId));

/// Provider for getting assignment by post ID
final assignmentByPostIdProvider =
    FutureProvider.family<AssignmentEntity, String>((ref, postId) async {
      final repository = ref.watch(submissionRepositoryProvider);
      return repository.getAssignmentByPostId(postId);
    });

/// Legacy provider name - kept for backward compatibility
/// Use assignmentByPostIdProvider instead
@Deprecated('Use assignmentByPostIdProvider with postId instead')
final assignmentPublicProvider = assignmentByPostIdProvider;

// ============ Parameter Classes ============

/// Parameters for student submissions provider
class StudentSubmissionsParams {
  final String assignmentId;
  final String studentId;

  const StudentSubmissionsParams({
    required this.assignmentId,
    required this.studentId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentSubmissionsParams &&
          runtimeType == other.runtimeType &&
          assignmentId == other.assignmentId &&
          studentId == other.studentId;

  @override
  int get hashCode => Object.hash(assignmentId, studentId);
}
