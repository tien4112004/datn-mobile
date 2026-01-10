import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFilters = selectedStatus != null || selectedGradeLevel != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(
              LucideIcons.settings,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Filters:',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            _buildFilterChip(
              context: context,
              label: selectedStatus?.displayName ?? 'All Status',
              icon: LucideIcons.info,
              isSelected: selectedStatus != null,
              onTap: () => _showStatusPicker(context),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context: context,
              label: selectedGradeLevel?.displayName ?? 'All Grades',
              icon: LucideIcons.graduationCap,
              isSelected: selectedGradeLevel != null,
              onTap: () => _showGradeLevelPicker(context),
            ),
            if (hasFilters) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(LucideIcons.x, size: 14),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronDown,
              size: 14,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Filter by Status',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.list),
              title: const Text('All Status'),
              selected: selectedStatus == null,
              onTap: () {
                onStatusChanged(null);
                Navigator.pop(context);
              },
            ),
            ...AssignmentStatus.values.map(
              (status) => ListTile(
                leading: Icon(_getStatusIcon(status)),
                title: Text(status.displayName),
                selected: selectedStatus == status,
                onTap: () {
                  onStatusChanged(status);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGradeLevelPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Filter by Grade Level',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.list),
              title: const Text('All Grades'),
              selected: selectedGradeLevel == null,
              onTap: () {
                onGradeLevelChanged(null);
                Navigator.pop(context);
              },
            ),
            ...GradeLevel.values.map(
              (grade) => ListTile(
                leading: const Icon(LucideIcons.graduationCap),
                title: Text(grade.displayName),
                selected: selectedGradeLevel == grade,
                onTap: () {
                  onGradeLevelChanged(grade);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
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
