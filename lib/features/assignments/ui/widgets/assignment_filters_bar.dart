import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExamFiltersBar extends ConsumerWidget {
  final GradeLevel? selectedGradeLevel;
  final ValueChanged<GradeLevel?> onGradeLevelChanged;
  final VoidCallback onClearFilters;

  const ExamFiltersBar({
    super.key,
    required this.selectedGradeLevel,
    required this.onGradeLevelChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return GenericFiltersBar(
      filters: [
        FilterConfig<GradeLevel>(
          label: t.assignments.filters.gradeLevel,
          icon: LucideIcons.graduationCap,
          selectedValue: selectedGradeLevel,
          options: GradeLevel.values,
          displayNameBuilder: (grade) => grade.getLocalizedName(t),
          onChanged: onGradeLevelChanged,
        ),
      ],
      onClearFilters: onClearFilters,
    );
  }
}
