import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/shared/widgets/generic_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExamFiltersBar extends StatelessWidget {
  final AssignmentStatus? selectedStatus;
  final GradeLevel? selectedGradeLevel;
  final ValueChanged<AssignmentStatus?> onStatusChanged;
  final ValueChanged<GradeLevel?> onGradeLevelChanged;
  final VoidCallback onClearFilters;

  const ExamFiltersBar({
    super.key,
    required this.selectedStatus,
    required this.selectedGradeLevel,
    required this.onStatusChanged,
    required this.onGradeLevelChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return GenericFiltersBar(
      filters: [
        FilterConfig<AssignmentStatus>(
          label: 'Status',
          icon: LucideIcons.info,
          selectedValue: selectedStatus,
          options: AssignmentStatus.values,
          displayNameBuilder: (status) => status.displayName,
          iconBuilder: (status) => _getStatusIcon(status),
          onChanged: onStatusChanged,
          allLabel: 'All Status',
          allIcon: LucideIcons.list,
        ),
        FilterConfig<GradeLevel>(
          label: 'Grade Level',
          icon: LucideIcons.graduationCap,
          selectedValue: selectedGradeLevel,
          options: GradeLevel.values,
          displayNameBuilder: (grade) => grade.displayName,
          onChanged: onGradeLevelChanged,
          allLabel: 'All Grades',
          allIcon: LucideIcons.list,
        ),
      ],
      onClearFilters: onClearFilters,
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
