import 'dart:async';

import 'package:datn_mobile/features/exams/data/repository/exam_repository_impl.dart';
import 'package:datn_mobile/features/exams/data/source/exam_mock_data_source.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_entity.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:datn_mobile/features/exams/domain/entity/matrix_item_entity.dart';
import 'package:datn_mobile/features/exams/domain/repository/exam_repository.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'exam_controller.dart';

/// Provider for the exam mock data source.
final examMockDataSourceProvider = Provider<ExamMockDataSource>((ref) {
  return ExamMockDataSource();
});

/// Provider for the exam repository.
final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final dataSource = ref.watch(examMockDataSourceProvider);
  return ExamRepositoryImpl(dataSource);
});

/// Provider for exams list controller.
final examsControllerProvider =
    AsyncNotifierProvider<ExamsController, List<ExamEntity>>(
      () => ExamsController(),
    );

/// Provider for detail exam controller.
final detailExamControllerProvider =
    AsyncNotifierProvider.family<DetailExamController, ExamEntity, String>(
      (String examId) => DetailExamController(examId: examId),
    );

/// Provider for creating a new exam.
final createExamControllerProvider =
    AsyncNotifierProvider<CreateExamController, void>(
      () => CreateExamController(),
    );

/// Provider for updating an exam.
final updateExamControllerProvider =
    AsyncNotifierProvider<UpdateExamController, void>(
      () => UpdateExamController(),
    );

/// Provider for deleting an exam.
final deleteExamControllerProvider =
    AsyncNotifierProvider<DeleteExamController, void>(
      () => DeleteExamController(),
    );

/// Provider for archiving an exam.
final archiveExamControllerProvider =
    AsyncNotifierProvider<ArchiveExamController, void>(
      () => ArchiveExamController(),
    );

/// Provider for duplicating an exam.
final duplicateExamControllerProvider =
    AsyncNotifierProvider<DuplicateExamController, void>(
      () => DuplicateExamController(),
    );

/// Provider for generating exam matrix.
final generateMatrixControllerProvider =
    AsyncNotifierProvider<GenerateMatrixController, void>(
      () => GenerateMatrixController(),
    );

/// Provider for generating questions.
final generateQuestionsControllerProvider =
    AsyncNotifierProvider<GenerateQuestionsController, void>(
      () => GenerateQuestionsController(),
    );
