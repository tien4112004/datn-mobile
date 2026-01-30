import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:AIPrimary/shared/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Header widget for Assignments page containing search bar and all filters inline
class AssignmentHeader extends ConsumerStatefulWidget {
  const AssignmentHeader({super.key});

  @override
  ConsumerState<AssignmentHeader> createState() => _AssignmentHeaderState();
}

class _AssignmentHeaderState extends ConsumerState<AssignmentHeader> {
  @override
  Widget build(BuildContext context) {
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
          CustomSearchBar(
            enabled: true,
            autoFocus: false,
            hintText: 'Search assignments...',
            initialValue: filterState.searchQuery,
            onSubmitted: (value) {
              final query = value.trim().isEmpty ? null : value.trim();
              filterNotifier.state = filterState.copyWith(searchQuery: query);
              assignmentsController.loadAssignmentsWithFilter();
            },
            onClearTap: () {
              filterNotifier.state = filterState.copyWith(searchQuery: null);
              assignmentsController.loadAssignmentsWithFilter();
            },
          ),

          const SizedBox(height: 12),
          GenericFiltersBar(
            filters: filterConfigs,
            onClearFilters: () {
              HapticFeedback.lightImpact();
              filterNotifier.state = filterState.clearFilters();
              assignmentsController.loadAssignmentsWithFilter();
            },
            useWrap: true,
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
