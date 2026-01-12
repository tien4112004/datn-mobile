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

  const QuestionBankState({
    this.questions = const [],
    this.currentBankType = BankType.personal,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.selectedQuestion,
    this.searchQuery,
  });

  QuestionBankState copyWith({
    List<QuestionBankItemEntity>? questions,
    BankType? currentBankType,
    QuestionBankItemEntity? selectedQuestion,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? searchQuery,
  }) {
    return QuestionBankState(
      questions: questions ?? this.questions,
      currentBankType: currentBankType ?? this.currentBankType,
      selectedQuestion: selectedQuestion ?? this.selectedQuestion,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
