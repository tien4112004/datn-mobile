import 'package:datn_mobile/features/generate/controllers/pods/models_controller_pod.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/generate/view/widgets/common/model_selector_field.dart';
import 'package:datn_mobile/features/generate/view/widgets/common/flex_dropdown_field.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/shared/widget/option_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Presentation-specific options widget
/// Contains: AI model selection, slides count, grade level, theme selection, avoid content
class PresentationOptionsSection extends ConsumerWidget {
  final TextEditingController slidesController;
  final int grade;
  final ValueChanged<int> onGradeChanged;
  final String theme;
  final ValueChanged<String> onThemeChanged;
  final TextEditingController avoidController;
  final ValueChanged<AIModel> onModelChanged;
  final VoidCallback? onInfoTap;

  const PresentationOptionsSection({
    super.key,
    required this.slidesController,
    required this.grade,
    required this.onGradeChanged,
    required this.theme,
    required this.onThemeChanged,
    required this.avoidController,
    required this.onModelChanged,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slideOptions = List.generate(5, (index) => '${index + 1} Slides');
    final gradeOptions = List.generate(5, (index) => 'Grade ${index + 1}');
    final selectedTextModel = ref.watch(textModelStatePod).selectedModel;

    return OptionBox(
      title: 'Options',
      showInfoDot: true,
      onInfoTap: onInfoTap,
      collapsedOptions: Column(
        children: [
          ModelSelectorField(
            resourceType: ResourceType.presentation,
            selectedModel: selectedTextModel,
            onModelChanged: onModelChanged,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FlexDropdownField(
                  label: 'Slides',
                  items: slideOptions,
                  currentValue: '${slidesController.text} Slides',
                  displayText: '${slidesController.text} Slides',
                  icon: LucideIcons.presentation,
                  onChanged: (value) {
                    // Extract number from "1 Slides" format
                    final slideCount =
                        int.tryParse(value.split(' ').first) ?? 1;
                    onGradeChanged(slideCount);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FlexDropdownField(
                  label: 'Grade',
                  items: gradeOptions,
                  currentValue: 'Grade $grade',
                  displayText: 'Grade $grade',
                  icon: LucideIcons.graduationCap,
                  onChanged: (value) {
                    // Extract number from "Grade 1" format
                    final gradeLevel = int.tryParse(value.split(' ').last) ?? 1;
                    onGradeChanged(gradeLevel);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      expandedOptions: Column(children: _buildAdvancedOptions()),
    );
  }

  List<Widget> _buildAdvancedOptions() {
    final themesOptions = List.generate(5, (index) => 'Theme ${index + 1}');

    return [
      Row(
        children: [
          FlexDropdownField(
            label: 'Theme',
            items: themesOptions,
            currentValue: 'Theme $theme',
            displayText: 'Theme $theme',
            icon: LucideIcons.graduationCap,
            onChanged: (value) {
              // Extract number from "Theme 1" format
              onThemeChanged(value);
            },
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(
        controller: avoidController,
        maxLines: 2,
        decoration: const InputDecoration(
          labelText: 'Avoid Content (optional)',
          hintText: 'E.g., politics, religion',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    ];
  }
}
