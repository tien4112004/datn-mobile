import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/shared/state/base_filter_state.dart';

class QuestionBankFilterState implements BaseFilterState {
  final BankType bankType;
  final String? searchQuery;
  final Grade? gradeFilter;
  final Subject? subjectFilter;
  final List<String> chapterFilters;
  final QuestionType? questionTypeFilter;
  final Difficulty? difficultyFilter;

  const QuestionBankFilterState({
    this.bankType = BankType.personal,
    this.searchQuery,
    this.gradeFilter,
    this.subjectFilter,
    this.chapterFilters = const [],
    this.questionTypeFilter,
    this.difficultyFilter,
  });

  @override
  QuestionBankFilterParams getFilterParams() {
    return QuestionBankFilterParams(
      bankType: bankType,
      searchQuery: searchQuery,
      gradeFilter: gradeFilter?.apiValue,
      subjectFilter: subjectFilter?.apiValue,
      chapterFilters: chapterFilters,
      questionTypeFilter: questionTypeFilter?.apiValue,
      difficultyFilter: difficultyFilter?.apiValue,
    );
  }

  QuestionBankFilterState copyWith({
    BankType? bankType,
    String? searchQuery,
    Grade? gradeFilter,
    Subject? subjectFilter,
    List<String>? chapterFilters,
    QuestionType? questionTypeFilter,
    Difficulty? difficultyFilter,
    Grade? grade,
    Subject? subject,
    QuestionType? questionType,
    Difficulty? difficulty,
  }) {
    return QuestionBankFilterState(
      bankType: bankType ?? this.bankType,
      searchQuery: searchQuery ?? this.searchQuery,
      gradeFilter: gradeFilter ?? this.gradeFilter,
      subjectFilter: subjectFilter ?? this.subjectFilter,
      chapterFilters: chapterFilters ?? this.chapterFilters,
      questionTypeFilter: questionTypeFilter ?? this.questionTypeFilter,
      difficultyFilter: difficultyFilter ?? this.difficultyFilter,
    );
  }

  QuestionBankFilterState clearFilters() {
    return copyWith(
      searchQuery: null,
      gradeFilter: null,
      subjectFilter: null,
      chapterFilters: const [],
      questionTypeFilter: null,
      difficultyFilter: null,
    );
  }

  bool get hasActiveFilters =>
      searchQuery != null ||
      gradeFilter != null ||
      subjectFilter != null ||
      chapterFilters.isNotEmpty ||
      questionTypeFilter != null ||
      difficultyFilter != null;
}

class QuestionBankFilterParams implements BaseFilterParams {
  final String? searchQuery;
  final String? gradeFilter;
  final String? subjectFilter;
  final List<String> chapterFilters;
  final String? questionTypeFilter;
  final String? difficultyFilter;
  final BankType bankType;

  const QuestionBankFilterParams({
    this.searchQuery,
    this.gradeFilter,
    this.subjectFilter,
    this.chapterFilters = const [],
    this.questionTypeFilter,
    this.difficultyFilter,
    this.bankType = BankType.personal,
  });
}
