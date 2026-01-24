import 'package:flutter/material.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';

class QuestionMetaRow extends StatelessWidget {
  final GradeLevel grade;
  final Subject subject;
  final Difficulty difficulty;
  final bool canEdit;
  final ValueChanged<GradeLevel>? onGradeChanged;
  final ValueChanged<Subject>? onSubjectChanged;
  final ValueChanged<Difficulty>? onDifficultyChanged;

  const QuestionMetaRow({
    super.key,
    required this.grade,
    required this.subject,
    required this.difficulty,
    this.canEdit = true,
    this.onGradeChanged,
    this.onSubjectChanged,
    this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Grade
          Expanded(
            child: _buildDropdown<GradeLevel>(
              context: context,
              value: grade,
              items: GradeLevel.values,
              onChanged: canEdit ? onGradeChanged : null,
              labelBuilder: (g) => g.displayName,
              icon: Icons.school_outlined,
              label: 'Grade',
            ),
          ),
          Container(
            height: 24,
            width: 1,
            color: colorScheme.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Subject
          Expanded(
            child: _buildDropdown<Subject>(
              context: context,
              value: subject,
              items: Subject.values,
              onChanged: canEdit ? onSubjectChanged : null,
              labelBuilder: (s) => s.displayName,
              icon: Icons.book_outlined,
              label: 'Subject',
            ),
          ),
          Container(
            height: 24,
            width: 1,
            color: colorScheme.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Difficulty
          Expanded(
            child: _buildDropdown<Difficulty>(
              context: context,
              value: difficulty,
              items: Difficulty.values,
              onChanged:
                  onDifficultyChanged, // Difficulty can usually be changed even in edit
              labelBuilder: (d) => d.displayName,
              icon: Icons.bar_chart_outlined,
              label: 'Level',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required T value,
    required List<T> items,
    required ValueChanged<T>? onChanged,
    required String Function(T) labelBuilder,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            isDense: true,
            icon: canEdit && onChanged != null
                ? Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: colorScheme.onSurface,
                  )
                : const SizedBox.shrink(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged != null
                ? (T? newValue) {
                    if (newValue != null) onChanged(newValue);
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
