part of 'question_bank_provider.dart';

class QuestionBankController extends AsyncNotifier<QuestionBankState> {
  @override
  QuestionBankState build() {
    return const QuestionBankState();
  }

  BankType get currentBankType => state.value!.currentBankType;

  /// Create questions
  Future<void> createQuestion(QuestionCreateRequestEntity request) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final result = await repository.createQuestions(
        List<QuestionCreateRequestEntity>.from([request]),
      );

      return QuestionBankState(
        questions: result.successful,
        currentBankType: state.value!.currentBankType,
        searchQuery: state.value!.searchQuery,
      );
    });
  }

  /// Loads questions based on current filters.
  Future<void> loadQuestions({
    BankType? bankType,
    String? search,
    bool refresh = false,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final currentBankType = bankType ?? state.value!.currentBankType;

      final result = await repository.getQuestions(
        bankType: currentBankType,
        page: 1,
        pageSize: 20,
        search: search,
      );

      return QuestionBankState(
        questions: result,
        currentBankType: currentBankType,
        searchQuery: search,
      );
    });
  }

  /// Switches between personal and public question banks.
  Future<void> switchBankType(BankType bankType) async {
    if (state.value?.currentBankType == bankType) return;

    state = AsyncValue.data(
      QuestionBankState(
        questions: state.value!.questions,
        currentBankType: bankType,
        searchQuery: state.value!.searchQuery,
      ),
    );

    await loadQuestions(bankType: bankType, refresh: true);
  }

  /// Performs search on current bank type.
  Future<void> search(String query) async {
    await loadQuestions(search: query, refresh: true);
  }

  /// Clears search filter.
  Future<void> clearSearch() async {
    await loadQuestions(search: '', refresh: true);
  }

  /// Deletes a question.
  Future<void> deleteQuestion(String id) async {
    // Remove from local state
    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final result = await repository.getQuestions(
        bankType: state.value!.currentBankType,
        page: 1,
        pageSize: 20,
        search: state.value!.searchQuery,
      );

      return QuestionBankState(
        questions: result,
        currentBankType: state.value!.currentBankType,
        searchQuery: state.value!.searchQuery,
      );
    });
  }

  /// Refreshes the current view.
  Future<void> refresh() async {
    await loadQuestions(refresh: true);
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
