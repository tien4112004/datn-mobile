import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/shared/state/base_filter_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_bank_filter_state.freezed.dart';

@freezed
abstract class QuestionBankFilterState
    with _$QuestionBankFilterState
    implements BaseFilterState {
  const QuestionBankFilterState._();

  const factory QuestionBankFilterState({
    @Default(BankType.personal) BankType bankType,
    String? searchQuery,
    GradeLevel? gradeFilter,
    Subject? subjectFilter,
    @Default([]) List<String> chapterFilters,
    QuestionType? questionTypeFilter,
    Difficulty? difficultyFilter,
  }) = _QuestionBankFilterState;

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

  // Computed properties for API compatibility
  String? get difficulty => difficultyFilter;
  String? get subject => subjectFilter;
  String? get type => questionTypeFilter;
  String? get grade => gradeFilter;
  String? get chapter =>
      chapterFilters.isNotEmpty ? chapterFilters.first : null;
}
