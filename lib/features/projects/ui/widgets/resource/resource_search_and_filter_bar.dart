import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/providers/filter_provider.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/widget/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A reusable widget that combines search bar with filter and sort options
/// Used for resource list pages (presentations, images, mindmaps, etc.)
class ResourceSearchAndFilterBar extends ConsumerWidget {
  final String hintText;
  final VoidCallback onSearchTap;
  final List<String> subjects;
  final List<String> grades;
  final String selectedSort;
  final List<String> sortOptions;
  final Function(String?) onSubjectChanged;
  final Function(String?) onGradeChanged;
  final Function(String) onSortChanged;
  final VoidCallback onClearFilters;

  const ResourceSearchAndFilterBar({
    super.key,
    required this.hintText,
    required this.onSearchTap,
    required this.subjects,
    required this.grades,
    required this.selectedSort,
    required this.sortOptions,
    required this.onSubjectChanged,
    required this.onGradeChanged,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final filterState = ref.watch(filterProvider);
    final hasActiveFilters =
        filterState.subject != null || filterState.grade != null;

    return Column(
      children: [
        // Search bar - opens dedicated search page
        InkWell(
          onTap: onSearchTap,
          child: CustomSearchBar(
            enabled: false,
            autoFocus: false,
            hintText: hintText,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 16),
        // Filter and Sort bar
        Row(
          children: [
            // Filter button group with horizontal scroll - left side
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // All button
                    TextButton(
                      onPressed: onClearFilters,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: !hasActiveFilters
                            ? Themes.theme.primaryColor
                            : Colors.transparent,
                        side: BorderSide(color: Themes.theme.primaryColor),
                      ),
                      child: Text(
                        t.projects.common_list.filter_all,
                        style: TextStyle(
                          color: !hasActiveFilters
                              ? Colors.white
                              : Themes.theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Subject dropdown
                    DropdownButton<String>(
                      value: filterState.subject,
                      hint: Text(t.projects.common_list.filter_subject),
                      items: subjects
                          .map(
                            (subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ),
                          )
                          .toList(),
                      onChanged: onSubjectChanged,
                      underline: Container(
                        height: 1,
                        color: Themes.theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Grade dropdown
                    DropdownButton<String>(
                      value: filterState.grade,
                      hint: Text(t.projects.common_list.filter_grade),
                      items: grades
                          .map(
                            (grade) => DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            ),
                          )
                          .toList(),
                      onChanged: onGradeChanged,
                      underline: Container(
                        height: 1,
                        color: Themes.theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Sort dropdown - right side
            DropdownButton<String>(
              value: selectedSort,
              items: sortOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                }
              },
              underline: Container(height: 1, color: Themes.theme.primaryColor),
              icon: const Icon(LucideIcons.arrowUpDown),
            ),
          ],
        ),
      ],
    );
  }
}
