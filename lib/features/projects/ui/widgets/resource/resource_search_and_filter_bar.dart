import 'package:datn_mobile/features/projects/providers/filter_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/filter_list.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/search_field.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/sort_button.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final Widget? trailing;

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
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final filterState = ref.watch(filterProvider);
    final hasActiveFilters =
        filterState.subject != null || filterState.grade != null;

    return Column(
      children: [
        SearchField(hintText: hintText, onTap: onSearchTap),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilterList(
                hasActiveFilters: hasActiveFilters,
                onClearFilters: onClearFilters,
                filterState: filterState,
                subjects: subjects,
                grades: grades,
                onSubjectChanged: onSubjectChanged,
                onGradeChanged: onGradeChanged,
                t: t,
              ),
            ),
            const SizedBox(width: 8),
            SortButton(
              selectedSort: selectedSort,
              sortOptions: sortOptions,
              onSortChanged: onSortChanged,
              t: t,
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ],
    );
  }
}
