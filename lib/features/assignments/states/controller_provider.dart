import 'dart:async';

import 'package:datn_mobile/features/assignments/data/repository/assignment_repository_impl.dart';
import 'package:datn_mobile/features/assignments/data/source/assignment_mock_data_source.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
import 'package:datn_mobile/features/assignments/domain/entity/matrix_item_entity.dart';
import 'package:datn_mobile/features/assignments/domain/repository/assignment_repository.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'assignment_controller.dart';

/// Provider for the assignment mock data source.
final assignmentMockDataSourceProvider = Provider<AssignmentMockDataSource>((
  ref,
) {
  return AssignmentMockDataSource();
});

/// Provider for the assignment repository.
final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  final dataSource = ref.watch(assignmentMockDataSourceProvider);
  return AssignmentRepositoryImpl(dataSource);
});

/// Provider for assignments list controller.
final assignmentsControllerProvider =
    AsyncNotifierProvider<AssignmentsController, List<AssignmentEntity>>(
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
    AsyncNotifierProvider<CreateAssignmentController, void>(
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

/// Provider for archiving an assignment.
final archiveAssignmentControllerProvider =
    AsyncNotifierProvider<ArchiveAssignmentController, void>(
      () => ArchiveAssignmentController(),
    );

/// Provider for duplicating an assignment.
final duplicateAssignmentControllerProvider =
    AsyncNotifierProvider<DuplicateAssignmentController, void>(
      () => DuplicateAssignmentController(),
    );

/// Provider for generating assignment matrix.
final generateMatrixControllerProvider =
    AsyncNotifierProvider<GenerateMatrixController, void>(
      () => GenerateMatrixController(),
    );

/// Provider for generating questions.
final generateQuestionsControllerProvider =
    AsyncNotifierProvider<GenerateQuestionsController, void>(
      () => GenerateQuestionsController(),
    );
