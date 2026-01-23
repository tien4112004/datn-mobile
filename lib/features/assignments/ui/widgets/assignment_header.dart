import 'package:datn_mobile/features/assignments/states/controller_provider.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/shared/widget/filter_chip_button.dart';
import 'package:datn_mobile/shared/widget/generic_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Header widget for Assignments page containing search bar and all filters inline
class AssignmentHeader extends ConsumerStatefulWidget {
  const AssignmentHeader({super.key});

  @override
  ConsumerState<AssignmentHeader> createState() => _AssignmentHeaderState();
}

class _AssignmentHeaderState extends ConsumerState<AssignmentHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize search controller with current filter state
    final currentFilter = ref.read(assignmentFilterProvider);
    if (currentFilter.searchQuery != null) {
      _searchController.text = currentFilter.searchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filterState = ref.watch(assignmentFilterProvider);
    final filterNotifier = ref.read(assignmentFilterProvider.notifier);
    final assignmentsController = ref.read(
      assignmentsControllerProvider.notifier,
    );

    final filterConfigs = List<BaseFilterConfig>.of([
      FilterConfig<AssignmentStatus>(
        label: 'Status',
        icon: LucideIcons.info,
        options: AssignmentStatus.values,
        allLabel: 'All Status',
        allIcon: LucideIcons.list,
        selectedValue: filterState.statusFilter,
        onChanged: (value) {
          filterNotifier.state = filterState.copyWith(statusFilter: value);
          assignmentsController.loadAssignmentsWithFilter();
        },
        displayNameBuilder: (value) => value.displayName,
        iconBuilder: (status) => _getStatusIcon(status),
      ),
      FilterConfig<GradeLevel>(
        label: 'Grade Level',
        icon: LucideIcons.graduationCap,
        options: GradeLevel.values,
        allLabel: 'All Grades',
        allIcon: LucideIcons.list,
        selectedValue: filterState.gradeLevelFilter,
        onChanged: (value) {
          filterNotifier.state = filterState.copyWith(gradeLevelFilter: value);
          assignmentsController.loadAssignmentsWithFilter();
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
          assignmentsController.loadAssignmentsWithFilter();
        },
        displayNameBuilder: (value) => value.displayName,
      ),
    ]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 96, bottom: 0),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search assignments...',
              prefixIcon: Icon(
                LucideIcons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        filterNotifier.state = filterState.copyWith(
                          searchQuery: null,
                        );
                        assignmentsController.loadAssignmentsWithFilter();
                        setState(() {});
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
            onChanged: (value) {
              setState(() {}); // Rebuild to show/hide clear button
            },
            onSubmitted: (value) {
              final query = value.trim().isEmpty ? null : value.trim();
              filterNotifier.state = filterState.copyWith(searchQuery: query);
              assignmentsController.loadAssignmentsWithFilter();
            },
            textInputAction: TextInputAction.search,
          ),

          const SizedBox(height: 12),

          // Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filterConfigs
                .map(
                  (filter) => FilterChipButton(
                    filter: filter,
                    onTap: () {
                      FilterChipButton.showFilterPicker(context, filter);
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.draft:
        return LucideIcons.file;
      case AssignmentStatus.generating:
        return LucideIcons.loader;
      case AssignmentStatus.completed:
        return LucideIcons.circleCheck;
      case AssignmentStatus.error:
        return LucideIcons.circleX;
      case AssignmentStatus.archived:
        return LucideIcons.archive;
    }
  }
}
