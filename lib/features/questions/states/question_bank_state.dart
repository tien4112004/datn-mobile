part of 'question_bank_provider.dart';

/// State class for Question Bank feature.
class QuestionBankState {
  final List<QuestionBankItemEntity> questions;
  final BankType currentBankType;
  final QuestionBankItemEntity? selectedQuestion;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? searchQuery;
  final Grade? gradeFilter;
  final Subject? subjectFilter;
  final String? chapterFilter;

  const QuestionBankState({
    this.questions = const [],
    this.currentBankType = BankType.personal,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.selectedQuestion,
    this.searchQuery,
    this.gradeFilter,
    this.subjectFilter,
    this.chapterFilter,
  });

  QuestionBankState copyWith({
    List<QuestionBankItemEntity>? questions,
    BankType? currentBankType,
    QuestionBankItemEntity? selectedQuestion,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? searchQuery,
    Grade? gradeFilter,
    Subject? subjectFilter,
    String? chapterFilter,
  }) {
    return QuestionBankState(
      questions: questions ?? this.questions,
      currentBankType: currentBankType ?? this.currentBankType,
      selectedQuestion: selectedQuestion ?? this.selectedQuestion,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      gradeFilter: gradeFilter ?? this.gradeFilter,
      subjectFilter: subjectFilter ?? this.subjectFilter,
      chapterFilter: chapterFilter ?? this.chapterFilter,
    );
  }
}
