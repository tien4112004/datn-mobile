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

    await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final result = await repository.createQuestions(
        List<QuestionCreateRequestEntity>.from([request]),
      );

      if (result.successful.isNotEmpty) {
        // Refresh the current view
        await loadQuestionsWithFilter();
      }
    });
  }

  /// Loads questions based on filter state.
  Future<void> loadQuestionsWithFilter() async {
    final filterParams = ref.read(questionBankFilterProvider).getFilterParams();

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);

      final result = await repository.getQuestions(
        bankType: filterParams.bankType,
        page: 1,
        pageSize: 20,
        search: filterParams.searchQuery,
        grade: filterParams.grade,
        chapter: filterParams.chapter,
        difficulty: filterParams.difficulty,
        subject: filterParams.subject,
        type: filterParams.type,
      );

      return state.value!.copyWith(questions: result);
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

      return state.value!.copyWith(questions: result);
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
    // Preserve current state before setting to loading
    final previousState = state.value ?? const QuestionBankState();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final result = await repository.getQuestionById(id);
      return previousState.copyWith(selectedQuestion: result);
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

      // Refresh the current view in background
      // unawaited(loadQuestionsWithFilter());

      debugPrint('Updated question: ${result.id}');

      return QuestionBankState(
        questions: state.value?.questions ?? [],
        selectedQuestion: result,
      );
    });
  }

  Future<void> publishQuestion(String questionId) async {
    final repository = ref.read(questionBankRepositoryProvider);
    await repository.publishQuestion(questionId);
  }
}
