part of 'question_bank_provider.dart';

class QuestionBankNotifier extends Notifier<QuestionBankState> {
  @override
  QuestionBankState build() {
    return const QuestionBankState();
  }

  /// Loads questions based on current filters.
  Future<void> loadQuestions({
    BankType? bankType,
    String? search,
    bool refresh = false,
  }) async {
    final targetBankType = bankType ?? state.currentBankType;
    final targetSearch = search ?? state.searchQuery;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentBankType: targetBankType,
        searchQuery: targetSearch,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final repository = ref.read(questionBankRepositoryProvider);
      final result = await repository.getQuestions(
        bankType: targetBankType,
        page: 1,
        pageSize: 20,
        search: targetSearch,
      );

      state = state.copyWith(
        questions: result,
        isLoading: false,
        currentBankType: targetBankType,
        searchQuery: targetSearch,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Switches between personal and public question banks.
  Future<void> switchBankType(BankType bankType) async {
    if (state.currentBankType == bankType) return;
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
    try {
      final repository = ref.read(questionBankRepositoryProvider);
      await repository.deleteQuestion(id);

      // Remove from local state
      state = state.copyWith(
        questions: state.questions.where((q) => q.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Refreshes the current view.
  Future<void> refresh() async {
    await loadQuestions(refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
