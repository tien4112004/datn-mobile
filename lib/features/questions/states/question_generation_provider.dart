import 'package:AIPrimary/features/questions/data/repository/question_bank_repository_provider.dart';
import 'package:AIPrimary/features/questions/domain/entity/generate_questions_request_entity.dart';
import 'package:AIPrimary/features/questions/states/question_generation_state.dart';
import 'package:AIPrimary/features/questions/states/question_bank_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class QuestionGenerationNotifier
    extends StateNotifier<QuestionGenerationState> {
  final Ref _ref;

  QuestionGenerationNotifier(this._ref)
    : super(const QuestionGenerationState());

  Future<void> generateQuestions(GenerateQuestionsRequestEntity entity) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = _ref.read(questionBankRepositoryProvider);
      final results = await repository.generateQuestions(entity);
      state = state.copyWith(isLoading: false, generatedQuestions: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearResults() {
    state = const QuestionGenerationState();
  }

  /// Saves all generated questions by refreshing the question bank.
  /// The backend already persisted the questions during generation,
  /// so this just reloads the bank to reflect them.
  Future<void> saveAll() async {
    if (state.generatedQuestions.isEmpty) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(questionBankProvider.notifier).loadQuestionsWithFilter();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final questionGenerationProvider =
    StateNotifierProvider<QuestionGenerationNotifier, QuestionGenerationState>(
      (ref) => QuestionGenerationNotifier(ref),
    );
