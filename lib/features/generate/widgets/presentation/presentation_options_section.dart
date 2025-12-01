import 'package:datn_mobile/shared/widget/option_box.dart';
import 'package:datn_mobile/shared/widget/option_field.dart';
import 'package:flutter/material.dart';

/// Presentation-specific options widget
/// Contains: slides count, grade level, theme selection, avoid content
class PresentationOptionsSection extends StatelessWidget {
  final TextEditingController slidesController;
  final int grade;
  final ValueChanged<int> onGradeChanged;
  final String theme;
  final ValueChanged<String> onThemeChanged;
  final TextEditingController avoidController;
  final VoidCallback? onInfoTap;

  const PresentationOptionsSection({
    super.key,
    required this.slidesController,
    required this.grade,
    required this.onGradeChanged,
    required this.theme,
    required this.onThemeChanged,
    required this.avoidController,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return OptionBox(
      title: 'Options',
      showInfoDot: true,
      onInfoTap: onInfoTap,
      collapsedOptions: _buildBasicOptions(),
      expandedOptions: _buildAdvancedOptions(),
    );
  }

  List<OptionRow> _buildBasicOptions() {
    return [
      OptionRow(
        first: TextInputOption(
          label: 'Slides',
          controller: slidesController,
          hint: 'Number of slides (1-50)...',
        ),
        second: SelectionOption(
          label: 'Grade',
          value: 'Grade $grade',
          items: const ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5'],
          onChanged: (v) {
            if (v != null) {
              final gradeNum = int.parse(v.replaceAll('Grade ', ''));
              onGradeChanged(gradeNum);
            }
          },
        ),
      ),
    ];
  }

  List<OptionRow> _buildAdvancedOptions() {
    return [
      OptionRow(
        first: SelectionOption(
          label: 'Themes',
          value: theme,
          items: const ['Lorems', 'Modern', 'Classic', 'Minimal'],
          onChanged: (v) {
            if (v != null) {
              onThemeChanged(v);
            }
          },
        ),
      ),
      OptionRow(
        first: TextInputOption(
          label: 'What to avoid in images',
          controller: avoidController,
          hint: 'Blood, violence...',
        ),
      ),
    ];
  }
}
