part of 'question_bank_provider.dart';

/// State class for Question Bank feature.
class QuestionBankState {
  final List<QuestionBankItemEntity> questions;
  final QuestionBankItemEntity? selectedQuestion;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const QuestionBankState({
    this.questions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.selectedQuestion,
  });

  QuestionBankState copyWith({
    List<QuestionBankItemEntity>? questions,
    BankType? currentBankType,
    QuestionBankItemEntity? selectedQuestion,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    QuestionBankFilterState? filterState,
  }) {
    return QuestionBankState(
      questions: questions ?? this.questions,
      selectedQuestion: selectedQuestion ?? this.selectedQuestion,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}
