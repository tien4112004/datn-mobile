part of 'controller_provider.dart';

/// Controller that holds the current assignment draft produced by AI generation.
class AssignmentGenerationController
    extends AsyncNotifier<AssignmentDraftEntity?> {
  @override
  Future<AssignmentDraftEntity?> build() async => null;

  Future<void> generateFromMatrix(
    GenerateAssignmentFromMatrixRequest req,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(assignmentRepositoryProvider)
          .generateAssignmentFromMatrix(req),
    );
  }

  Future<void> generateFull(GenerateFullAssignmentRequest req) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(assignmentRepositoryProvider)
          .generateFullAssignment(req),
    );
  }

  void clearDraft() => state = const AsyncData(null);
}
