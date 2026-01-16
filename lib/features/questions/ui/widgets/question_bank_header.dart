import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/ui/widgets/bank_type_switcher.dart';
import 'package:datn_mobile/shared/widget/generic_filters_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
        bottom: 0,
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
          // Generic filters bar
          GenericFiltersBar(
            filters: [
              FilterConfig<Grade>(
                label: 'Grade',
                icon: LucideIcons.graduationCap,
                selectedValue: selectedGrade,
                options: Grade.values,
                displayNameBuilder: (grade) => grade.displayName,
                onChanged: onGradeChanged,
                allLabel: 'All Grades',
                allIcon: LucideIcons.list,
              ),
              FilterConfig<Subject>(
                label: 'Subject',
                icon: LucideIcons.bookOpen,
                selectedValue: selectedSubject,
                options: Subject.values,
                displayNameBuilder: (subject) => subject.displayName,
                onChanged: onSubjectChanged,
                allLabel: 'All Subjects',
                allIcon: LucideIcons.list,
              ),
            ],
            onClearFilters: onClearFilters,
          ),
        ],
      ),
    );
  }
}
