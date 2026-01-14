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
    Grade? grade,
    Subject? subject,
    String? chapter,
    bool refresh = false,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final currentState = state.value!;
      final currentBankType = bankType ?? currentState.currentBankType;

      final result = await repository.getQuestions(
        bankType: currentBankType,
        page: 1,
        pageSize: 20,
        search: search ?? currentState.searchQuery,
        grade: grade?.apiValue ?? currentState.gradeFilter?.apiValue,
        chapter: chapter ?? currentState.chapterFilter,
      );

      return QuestionBankState(
        questions: result,
        currentBankType: currentBankType,
        searchQuery: search ?? currentState.searchQuery,
        gradeFilter: grade ?? currentState.gradeFilter,
        chapterFilter: chapter ?? currentState.chapterFilter,
      );
    });
  }

  /// Switches between personal and public question banks.
  Future<void> switchBankType(BankType bankType) async {
    if (state.value?.currentBankType == bankType) return;

    final currentState = state.value!;
    state = AsyncValue.data(
      QuestionBankState(
        questions: currentState.questions,
        currentBankType: bankType,
        searchQuery: currentState.searchQuery,
        gradeFilter: currentState.gradeFilter,
        chapterFilter: currentState.chapterFilter,
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

  /// Sets grade filter and reloads questions.
  Future<void> setGradeFilter(String? grade) async {
    await loadQuestions(grade: Grade.fromApiValue(grade), refresh: true);
  }

  /// Sets chapter filter and reloads questions.
  Future<void> setChapterFilter(String? chapter) async {
    await loadQuestions(chapter: chapter, refresh: true);
  }

  /// Sets subject filter and reloads questions.
  Future<void> setSubjectFilter(Subject? subject) async {
    await loadQuestions(subject: subject, refresh: true);
  }

  /// Clears all filters (search, grade, chapter, subject).
  Future<void> clearFilters() async {
    await loadQuestions(
      search: '',
      grade: null,
      subject: null,
      chapter: null,
      refresh: true,
    );
  }

  /// Deletes a question.
  Future<void> deleteQuestion(String id) async {
    // Remove from local state
    state = await AsyncValue.guard(() async {
      final repository = ref.read(questionBankRepositoryProvider);
      final currentState = state.value!;
      final result = await repository.getQuestions(
        bankType: currentState.currentBankType,
        page: 1,
        pageSize: 20,
        search: currentState.searchQuery,
        grade: currentState.gradeFilter!.apiValue,
        chapter: currentState.chapterFilter,
      );

      return QuestionBankState(
        questions: result,
        currentBankType: currentState.currentBankType,
        searchQuery: currentState.searchQuery,
        gradeFilter: currentState.gradeFilter,
        chapterFilter: currentState.chapterFilter,
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
