import 'package:datn_mobile/features/assignments/states/controller_provider.dart';
import 'package:datn_mobile/features/assignments/ui/widgets/advanced_assignment_filter_dialog.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/shared/widget/filter_chip_button.dart';
import 'package:datn_mobile/shared/widget/generic_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Header widget for Assignments page containing filters
class AssignmentHeader extends ConsumerWidget {
  const AssignmentHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
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
          assignmentsController.refresh();
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
          assignmentsController.refresh();
        },
        displayNameBuilder: (value) => value.displayName,
      ),
    ]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 96, bottom: 0),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Wrap(
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
            onTap: () =>
                showAdvancedAssignmentFilterDialog(context: context, ref: ref),
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
