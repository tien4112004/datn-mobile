import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExamFiltersBar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return GenericFiltersBar(
      filters: [
        FilterConfig<AssignmentStatus>(
          label: t.assignments.filters.status,
          icon: LucideIcons.info,
          selectedValue: selectedStatus,
          options: AssignmentStatus.values,
          displayNameBuilder: (status) => status.getLocalizedName(t),
          iconBuilder: (status) => _getStatusIcon(status),
          onChanged: onStatusChanged,
          allLabel: t.assignments.filters.allStatus,
          allIcon: LucideIcons.list,
        ),
        FilterConfig<GradeLevel>(
          label: t.assignments.filters.gradeLevel,
          icon: LucideIcons.graduationCap,
          selectedValue: selectedGradeLevel,
          options: GradeLevel.values,
          displayNameBuilder: (grade) => grade.getLocalizedName(t),
          onChanged: onGradeLevelChanged,
          allLabel: t.assignments.filters.allGrades,
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
