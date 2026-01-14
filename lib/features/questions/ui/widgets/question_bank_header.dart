import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/ui/widgets/bank_type_switcher.dart';
import 'package:datn_mobile/shared/widget/flex_dropdown_field.dart';

/// Header widget for Question Bank page containing bank switcher and search
class QuestionBankHeader extends StatelessWidget {
  final BankType selectedType;
  final ValueChanged<BankType> onTypeChanged;
  final TextEditingController searchController;
  final Grade? selectedGrade;
  final Subject? selectedSubject;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchCleared;
  final VoidCallback onSearchChanged;
  final ValueChanged<Grade?> onGradeChanged;
  final ValueChanged<Subject?> onSubjectChanged;
  final VoidCallback onClearFilters;

  const QuestionBankHeader({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.searchController,
    this.selectedGrade,
    this.selectedSubject,
    required this.onSearchSubmitted,
    required this.onSearchCleared,
    required this.onSearchChanged,
    required this.onGradeChanged,
    required this.onSubjectChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 80, // Space for app bar + title
        bottom: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bank type switcher
          BankTypeSwitcher(
            selectedType: selectedType,
            onTypeChanged: onTypeChanged,
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search questions...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: onSearchCleared,
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
            onSubmitted: onSearchSubmitted,
            onChanged: (_) => onSearchChanged(),
          ),
          const SizedBox(height: 12),
          // Filter row for Grade and Subject
          Row(
            children: [
              // Grade dropdown filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(
                        'Grade',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    FlexDropdownField<Grade>(
                      value: selectedGrade ?? Grade.grade1,
                      items: Grade.values,
                      onChanged: onGradeChanged,
                      itemLabelBuilder: (grade) => grade.displayName,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              //Subject dropdown filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    FlexDropdownField<Subject>(
                      value: selectedSubject ?? Subject.english,
                      items: Subject.values,
                      onChanged: onSubjectChanged,
                      itemLabelBuilder: (subject) => subject.displayName,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Clear filters button
              IconButton(
                icon: const Icon(Icons.filter_alt_off_outlined),
                onPressed: onClearFilters,
                tooltip: 'Clear Filters',
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  foregroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
