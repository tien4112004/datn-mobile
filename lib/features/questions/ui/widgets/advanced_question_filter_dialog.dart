import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/states/question_bank_filter_state.dart';
import 'package:AIPrimary/features/questions/states/question_bank_provider.dart';
import 'package:AIPrimary/features/questions/ui/widgets/chapter_filter_widget.dart';
import 'package:AIPrimary/shared/widgets/advanced_filter_dialog.dart';
import 'package:AIPrimary/shared/widgets/filter_chip_button.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the advanced question filter dialog with draft pattern
///
/// This dialog uses the Draft Pattern:
/// - Creates a local copy of the filter state
/// - User makes changes to the draft
/// - Only when "Apply" is clicked, the draft is committed to the provider
/// - This prevents unnecessary data fetching while user is experimenting with filters
void showAdvancedQuestionFilterDialog({
  required BuildContext context,
  required WidgetRef ref,
}) {
  // Get current filter state
  final currentFilterState = ref.read(questionBankFilterProvider);

  // Initialize draft state with current values
  QuestionBankFilterState draftState = currentFilterState;
  List<String> draftChapters = List.from(currentFilterState.chapterFilters);

  showAdvancedFilterDialog(
    context: context,
    title: 'Question Filters',
    content: StatefulBuilder(
      builder: (context, setState) {
        // Create filter configs with draft state
        final filterConfigs = List<BaseFilterConfig>.of([
          FilterConfig<GradeLevel>(
            label: 'Grade',
            icon: LucideIcons.graduationCap,
            options: GradeLevel.values,
            allLabel: 'All Grades',
            allIcon: LucideIcons.list,
            selectedValue: draftState.gradeFilter,
            onChanged: (value) {
              setState(() {
                draftState = draftState.copyWith(gradeFilter: value);
              });
            },
            displayNameBuilder: (value) => value.displayName,
          ),
          FilterConfig<Subject>(
            label: 'Subject',
            icon: LucideIcons.bookOpen,
            options: Subject.values,
            allLabel: 'All Subjects',
            allIcon: LucideIcons.list,
            selectedValue: draftState.subjectFilter,
            onChanged: (value) {
              setState(() {
                draftState = draftState.copyWith(subjectFilter: value);
              });
            },
            displayNameBuilder: (value) => value.displayName,
          ),
          FilterConfig<QuestionType>(
            label: 'Type',
            icon: LucideIcons.circleQuestionMark,
            options: QuestionType.values,
            allLabel: 'All Types',
            allIcon: LucideIcons.list,
            selectedValue: draftState.questionTypeFilter,
            onChanged: (value) {
              setState(() {
                draftState = draftState.copyWith(questionTypeFilter: value);
              });
            },
            displayNameBuilder: (value) => value.displayName,
          ),
          FilterConfig<Difficulty>(
            label: 'Difficulty',
            icon: LucideIcons.gauge,
            options: Difficulty.values,
            allLabel: 'All Difficulties',
            allIcon: LucideIcons.list,
            selectedValue: draftState.difficultyFilter,
            onChanged: (value) {
              setState(() {
                draftState = draftState.copyWith(difficultyFilter: value);
              });
            },
            displayNameBuilder: (value) => value.displayName,
          ),
        ]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips display
            _buildFiltersSection(context, filterConfigs),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Chapter filters
            ChapterFilterWidget(
              currentGrade: draftState.gradeFilter,
              currentSubject: draftState.subjectFilter,
              initialSelectedChapters: draftChapters,
              onChaptersChanged: (chapters) {
                setState(() {
                  draftChapters = chapters;
                });
              },
            ),
          ],
        );
      },
    ),
    onClearAll: () {
      draftState = const QuestionBankFilterState();
      draftChapters = [];

      ref.read(questionBankFilterProvider.notifier).state = draftState;
      ref.read(questionBankProvider.notifier).loadQuestionsWithFilter();

      // Close the dialog
      context.router.maybePop();
    },
    onApply: () {
      final finalState = draftState.copyWith(chapterFilters: draftChapters);
      ref.read(questionBankFilterProvider.notifier).state = finalState;

      ref.read(questionBankProvider.notifier).loadQuestionsWithFilter();
    },
    applyButtonText: 'Apply Filters',
  );
}

/// Build the filters section with chips
Widget _buildFiltersSection(
  BuildContext context,
  List<BaseFilterConfig> filters,
) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            LucideIcons.listFilter,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Quick Filters',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters.map((filter) {
          return FilterChipButton(
            filter: filter,
            onTap: () {
              FilterChipButton.showFilterPicker(context, filter);
            },
          );
        }).toList(),
      ),
    ],
  );
}
