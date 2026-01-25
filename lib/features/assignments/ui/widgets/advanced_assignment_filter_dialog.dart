import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/assignments/states/assignment_filter_state.dart';
import 'package:datn_mobile/features/assignments/states/controller_provider.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/shared/widgets/advanced_filter_dialog.dart';
import 'package:datn_mobile/shared/widgets/filter_chip_button.dart';
import 'package:datn_mobile/shared/widgets/generic_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the advanced assignment filter dialog with draft pattern
///
/// This dialog uses the Draft Pattern:
/// - Creates a local copy of the filter state
/// - User makes changes to the draft
/// - Only when "Apply" is clicked, the draft is committed to the provider
/// - This prevents unnecessary data fetching while user is experimenting with filters
void showAdvancedAssignmentFilterDialog({
  required BuildContext context,
  required WidgetRef ref,
}) {
  // Get current filter state
  final currentFilterState = ref.read(assignmentFilterProvider);

  // Initialize draft state with current values
  AssignmentFilterState draftState = currentFilterState;

  showAdvancedFilterDialog(
    context: context,
    title: 'Assignment Filters',
    content: StatefulBuilder(
      builder: (context, setState) {
        // Create filter configs with draft state
        final filterConfigs = List<BaseFilterConfig>.of([
          FilterConfig<AssignmentStatus>(
            label: 'Status',
            icon: LucideIcons.info,
            options: AssignmentStatus.values,
            allLabel: 'All Status',
            allIcon: LucideIcons.list,
            selectedValue: draftState.statusFilter,
            onChanged: (value) {
              setState(() {
                draftState = draftState.copyWith(statusFilter: value);
              });
            },
            displayNameBuilder: (value) => value.displayName,
            iconBuilder: (status) => AssignmentStatus.getStatusIcon(status),
          ),
          FilterConfig<GradeLevel>(
            label: 'Grade Level',
            icon: LucideIcons.graduationCap,
            options: GradeLevel.values,
            allLabel: 'All Grades',
            allIcon: LucideIcons.list,
            selectedValue: draftState.gradeLevelFilter,
            onChanged: (value) {
              setState(() {
                draftState = draftState.copyWith(gradeLevelFilter: value);
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
        ]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips display
            _buildFiltersSection(context, filterConfigs),
            const SizedBox(height: 16),
            // TODO: Add topic filter input field here if needed
          ],
        );
      },
    ),
    onClearAll: () {
      draftState = const AssignmentFilterState();

      ref.read(assignmentFilterProvider.notifier).state = draftState;
      ref.read(assignmentsControllerProvider.notifier).refresh();

      // Close the dialog
      context.router.maybePop();
    },
    onApply: () {
      // Commit draft to provider only when user clicks apply
      ref.read(assignmentFilterProvider.notifier).state = draftState;

      // Trigger data reload
      ref.read(assignmentsControllerProvider.notifier).refresh();
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
