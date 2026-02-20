import 'package:AIPrimary/features/questions/domain/entity/question_bank_item_entity.dart';

class QuestionGenerationState {
  final bool isLoading;
  final List<QuestionBankItemEntity> generatedQuestions;
  final String? error;

  const QuestionGenerationState({
    this.isLoading = false,
    this.generatedQuestions = const [],
    this.error,
  });

  QuestionGenerationState copyWith({
    bool? isLoading,
    List<QuestionBankItemEntity>? generatedQuestions,
    String? error,
  }) {
    return QuestionGenerationState(
      isLoading: isLoading ?? this.isLoading,
      generatedQuestions: generatedQuestions ?? this.generatedQuestions,
      error: error,
    );
  }
}
