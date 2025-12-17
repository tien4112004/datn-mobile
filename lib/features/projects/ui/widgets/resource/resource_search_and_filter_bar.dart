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

                    // Subject dropdown
                    PopupMenuButton<String?>(
                      initialValue: filterState.subject,
                      onSelected: onSubjectChanged,
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String?>(
                          value: null,
                          child: Text(t.projects.common_list.filter_subject),
                        ),
                        ...subjects.map(
                          (subject) => PopupMenuItem<String?>(
                            value: subject,
                            child: Text(subject),
                          ),
                        ),
                      ],
                      child: OutlinedButton.icon(
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(LucideIcons.chevronDown, size: 16),
                        onPressed: null,
                        label: Text(
                          filterState.subject ??
                              t.projects.common_list.filter_subject,
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: hasActiveFilters
                              ? Colors.blue.shade100
                              : Colors.grey.shade100,
                          padding: EdgeInsets.symmetric(
                            horizontal: Themes.padding.p12,
                            vertical: Themes.padding.p8,
                          ),
                          side: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Grade dropdown
                    PopupMenuButton<String?>(
                      initialValue: filterState.grade,
                      onSelected: onGradeChanged,
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String?>(
                          value: null,
                          child: Text(t.projects.common_list.filter_grade),
                        ),
                        ...grades.map(
                          (grade) => PopupMenuItem<String?>(
                            value: grade,
                            child: Text(grade),
                          ),
                        ),
                      ],
                      child: OutlinedButton.icon(
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(LucideIcons.chevronDown, size: 16),
                        onPressed: null,
                        label: Text(
                          filterState.grade ??
                              t.projects.common_list.filter_grade,
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: hasActiveFilters
                              ? Colors.blue.shade100
                              : Colors.grey.shade100,
                          padding: EdgeInsets.symmetric(
                            horizontal: Themes.padding.p12,
                            vertical: Themes.padding.p8,
                          ),
                          side: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Sort dropdown - right side
            PopupMenuButton<String>(
              initialValue: selectedSort,
              onSelected: onSortChanged,
              itemBuilder: (BuildContext context) => sortOptions
                  .map(
                    (option) => PopupMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList(),
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(LucideIcons.arrowUpDown, size: 16),
                label: Text(
                  t.projects.sort,
                  style: const TextStyle(fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  padding: EdgeInsets.symmetric(
                    horizontal: Themes.padding.p12,
                    vertical: Themes.padding.p8,
                  ),
                  side: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
