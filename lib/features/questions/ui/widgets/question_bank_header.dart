import 'package:datn_mobile/features/questions/states/question_bank_provider.dart';
import 'package:datn_mobile/features/questions/ui/widgets/advanced_question_filter_dialog.dart';
import 'package:datn_mobile/shared/widget/filter_chip_button.dart';
import 'package:datn_mobile/shared/widget/generic_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/features/questions/ui/widgets/bank_type_switcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Header widget for Question Bank page containing bank switcher, search, and filters
class QuestionBankHeader extends ConsumerWidget {
  final TextEditingController _searchController = TextEditingController(
    text: "",
  );

  QuestionBankHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final filterState = ref.watch(questionBankFilterProvider);
    final filterNotifier = ref.read(questionBankFilterProvider.notifier);
    final questionbankController = ref.watch(questionBankProvider.notifier);

    final filterConfigs = List<BaseFilterConfig>.of([
      FilterConfig<GradeLevel>(
        label: 'Grade',
        icon: LucideIcons.graduationCap,
        options: GradeLevel.values,
        allLabel: 'All Grades',
        allIcon: LucideIcons.list,
        selectedValue: filterState.gradeFilter,
        onChanged: (value) {
          filterNotifier.state = filterState.copyWith(gradeFilter: value);
          questionbankController.loadQuestionsWithFilter();
        },
        displayNameBuilder: (value) => value.displayName,
      ),
      FilterConfig<Subject>(
        label: 'Subject',
        icon: LucideIcons.bookOpen,
        options: Subject.values,
        allLabel: 'All Subjects',
        allIcon: LucideIcons.list,
        selectedValue: filterState.subjectFilter,
        onChanged: (value) {
          filterNotifier.state = filterState.copyWith(subjectFilter: value);
          questionbankController.loadQuestionsWithFilter();
        },
        displayNameBuilder: (value) => value.displayName,
      ),
      FilterConfig<QuestionType>(
        label: 'Type',
        icon: LucideIcons.circleQuestionMark,
        options: QuestionType.values,
        allLabel: 'All Types',
        allIcon: LucideIcons.list,
        selectedValue: filterState.questionTypeFilter,
        onChanged: (value) {
          filterNotifier.state = filterState.copyWith(
            questionTypeFilter: value,
          );
          questionbankController.loadQuestionsWithFilter();
        },
        displayNameBuilder: (value) => value.displayName,
      ),
      FilterConfig<Difficulty>(
        label: 'Difficulty',
        icon: LucideIcons.gauge,
        options: Difficulty.values,
        allLabel: 'All Difficulties',
        allIcon: LucideIcons.list,
        selectedValue: filterState.difficultyFilter,
        onChanged: (value) {
          filterNotifier.state = filterState.copyWith(difficultyFilter: value);
          questionbankController.loadQuestionsWithFilter();
        },
        displayNameBuilder: (value) => value.displayName,
      ),
    ]);

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 80, // Space for app bar + title
        bottom: 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bank type switcher
          BankTypeSwitcher(
            selectedType: filterState.bankType,
            onTypeChanged: (type) {
              filterNotifier.state = filterState.copyWith(bankType: type);
              questionbankController.loadQuestionsWithFilter();
            },
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search questions...',
              prefixIcon: const Icon(LucideIcons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () {
                        _searchController.clear();
                        filterNotifier.state = filterState.copyWith(
                          searchQuery: null,
                        );
                        questionbankController.loadQuestionsWithFilter();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            onSubmitted: (query) {
              filterNotifier.state = filterState.copyWith(
                searchQuery: query.isEmpty ? null : query,
              );
              questionbankController.loadQuestionsWithFilter();
            },
            onChanged: (query) {
              // Only update state, don't trigger search until user submits
              filterNotifier.state = filterState.copyWith(
                searchQuery: query.isEmpty ? null : query,
              );
            },
          ),
          const SizedBox(height: 12),
          // Feature filters bar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...filterConfigs.map(
                (filter) => FilterChipButton(
                  filter: filter,
                  onTap: () {
                    FilterChipButton.showFilterPicker(context, filter);
                  },
                ),
              ),
              // Advanced filter button
              InkWell(
                onTap: () => showAdvancedQuestionFilterDialog(
                  context: context,
                  ref: ref,
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.secondary, width: 1),
                  ),
                  child: Icon(
                    LucideIcons.slidersHorizontal,
                    size: 16,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
