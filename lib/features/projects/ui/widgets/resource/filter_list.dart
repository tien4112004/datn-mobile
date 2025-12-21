import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/providers/filter_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/filter_dropdown.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class FilterList extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final FilterState filterState;
  final List<String> subjects;
  final List<String> grades;
  final Function(String?) onSubjectChanged;
  final Function(String?) onGradeChanged;
  final Translations t;

  const FilterList({
    super.key,
    required this.hasActiveFilters,
    required this.onClearFilters,
    required this.filterState,
    required this.subjects,
    required this.grades,
    required this.onSubjectChanged,
    required this.onGradeChanged,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onClearFilters,
            style: OutlinedButton.styleFrom(
              backgroundColor: !hasActiveFilters
                  ? Colors.blue.shade100
                  : Colors.grey.shade100,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: Text(
              t.projects.common_list.filter_all,
              style: TextStyle(fontSize: Themes.fontSize.s14),
            ),
          ),
          const SizedBox(width: 8),
          FilterDropdown(
            value: filterState.subject,
            items: subjects,
            label: t.projects.common_list.filter_subject,
            onChanged: onSubjectChanged,
            isActive: hasActiveFilters,
          ),
          const SizedBox(width: 8),
          FilterDropdown(
            value: filterState.grade,
            items: grades,
            label: t.projects.common_list.filter_grade,
            onChanged: onGradeChanged,
            isActive: hasActiveFilters,
          ),
        ],
      ),
    );
  }
}
