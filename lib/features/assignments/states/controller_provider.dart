import 'dart:async';

import 'package:AIPrimary/features/assignments/data/dto/api/assignment_create_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_update_request.dart';
import 'package:AIPrimary/features/assignments/data/repository/assignment_repository_impl.dart';
import 'package:AIPrimary/features/assignments/data/repository/context_repository_impl.dart';
import 'package:AIPrimary/features/assignments/data/source/assignment_remote_source.dart';
import 'package:AIPrimary/features/assignments/data/source/context_remote_source.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/domain/repository/assignment_repository.dart';
import 'package:AIPrimary/features/assignments/domain/repository/context_repository.dart';
import 'package:AIPrimary/features/assignments/states/assignment_filter_state.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:AIPrimary/shared/utils/matrix_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

part 'assignment_controller.dart';
part 'context_controller.dart';

/// Provider for assignment filter state
final assignmentFilterProvider = StateProvider<AssignmentFilterState>((ref) {
  return const AssignmentFilterState();
});

/// Provider for the assignment data source.
final assignmentRemoteSourceProvider = Provider<AssignmentRemoteSource>((ref) {
  return AssignmentRemoteSource(ref.watch(dioPod));
});

/// Provider for the assignment repository.
final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  final dataSource = ref.watch(assignmentRemoteSourceProvider);
  return AssignmentRepositoryImpl(dataSource);
});

/// Provider for assignments list controller.
final assignmentsControllerProvider =
    AsyncNotifierProvider<AssignmentsController, AssignmentListResult>(
      () => AssignmentsController(),
    );

/// Provider for detail assignment controller.
final detailAssignmentControllerProvider =
    AsyncNotifierProvider.family<
      DetailAssignmentController,
      AssignmentEntity,
      String
    >(
      (String assignmentId) =>
          DetailAssignmentController(assignmentId: assignmentId),
    );

/// Provider for creating a new exam.
final createAssignmentControllerProvider =
    AsyncNotifierProvider<CreateAssignmentController, AssignmentEntity?>(
      () => CreateAssignmentController(),
    );

/// Provider for updating an assignment.
final updateAssignmentControllerProvider =
    AsyncNotifierProvider<UpdateAssignmentController, void>(
      () => UpdateAssignmentController(),
    );

/// Provider for deleting an assignment.
final deleteAssignmentControllerProvider =
    AsyncNotifierProvider<DeleteAssignmentController, void>(
      () => DeleteAssignmentController(),
    );

// ============================================================================
// Context Providers
// ============================================================================

/// Provider for the context remote data source.
final contextRemoteSourceProvider = Provider<ContextRemoteSource>((ref) {
  return ContextRemoteSource(ref.watch(dioPod));
});

/// Provider for the context repository.
final contextRepositoryProvider = Provider<ContextRepository>((ref) {
  final dataSource = ref.watch(contextRemoteSourceProvider);
  return ContextRepositoryImpl(dataSource);
});

/// Provider for contexts list controller (for context selector).
final contextsControllerProvider =
    AsyncNotifierProvider<ContextsController, ContextListResult>(
      () => ContextsController(),
    );

/// Provider for assignment-specific contexts controller.
/// Manages cloned contexts within a specific assignment.
final assignmentContextsControllerProvider =
    AsyncNotifierProvider.family<
      AssignmentContextsController,
      List<ContextEntity>,
      String
    >(
      (assignmentId) =>
          AssignmentContextsController(assignmentId: assignmentId),
    );
