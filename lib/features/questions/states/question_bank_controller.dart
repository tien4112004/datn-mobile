part of 'question_bank_provider.dart';

class QuestionBankController extends AsyncNotifier<QuestionBankState> {
  @override
  QuestionBankState build() {
    return const QuestionBankState();
  }

  void updateFilterState(QuestionBankFilterState newFilterState) {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(filterState: newFilterState));
    }
  }

  /// Create questions
  Future<void> createQuestion(QuestionCreateRequestEntity request) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final result = await repository.createQuestions(
        List<QuestionCreateRequestEntity>.from([request]),
      );

      return QuestionBankState(questions: result.successful);
    });
  }

  /// Loads questions based on filter state.
  Future<void> loadQuestionsWithFilter() async {
    final filterParams = ref.read(questionBankFilterProvider).getFilterParams();

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);

      final chapterParam = filterParams.chapterFilters.isNotEmpty
          ? filterParams.chapterFilters.first
          : null;

      final result = await repository.getQuestions(
        bankType: filterParams.bankType,
        page: 1,
        pageSize: 20,
        search: filterParams.searchQuery,
        grade: filterParams.gradeFilter,
        chapter: chapterParam,
      );

      return QuestionBankState(questions: result);
    });
  }

  Future<void> loadQuestions() async {
    final filterParams = ref.read(questionBankFilterProvider).getFilterParams();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);

      final result = await repository.getQuestions(
        bankType: filterParams.bankType,
      );

      return QuestionBankState(questions: result);
    });
  }

  Future<void> deleteQuestion(String id) async {
    await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      await repository.deleteQuestion(id);
    });

    // Refresh the current view
    await loadQuestions();
  }

  Future<void> getQuestionById(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final result = await repository.getQuestionById(id);
      return state.value!.copyWith(selectedQuestion: result);
    });
  }

  Future<void> updateQuestion(
    String id,
    QuestionUpdateRequestEntity questionUpdateRequestEntity,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final result = await repository.updateQuestion(
        id,
        questionUpdateRequestEntity,
      );
      return state.value!.copyWith(selectedQuestion: result);
    });
  }
}
