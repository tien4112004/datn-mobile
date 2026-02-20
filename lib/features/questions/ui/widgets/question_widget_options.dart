import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/widgets/flex_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Widget option builders for [QuestionGeneratePage]'s [GenerationSettingsSheet].
///
/// Mirrors the pattern of [PresentationWidgetOptions] but uses plain
/// [StatefulBuilder] callbacks rather than Riverpod providers, since the
/// question page manages its own local state.
class QuestionWidgetOptions {
  final GradeLevel grade;
  final Subject subject;
  final Set<QuestionType> selectedTypes;
  final Map<Difficulty, int> difficultyCounts;
  final TextEditingController promptController;
  final void Function(GradeLevel) onGradeChanged;
  final void Function(Subject) onSubjectChanged;
  final void Function(Set<QuestionType>) onTypesChanged;
  final void Function(Map<Difficulty, int>) onDifficultyChanged;

  const QuestionWidgetOptions({
    required this.grade,
    required this.subject,
    required this.selectedTypes,
    required this.difficultyCounts,
    required this.promptController,
    required this.onGradeChanged,
    required this.onSubjectChanged,
    required this.onTypesChanged,
    required this.onDifficultyChanged,
  });

  List<Widget> buildAllSettings(Translations t) {
    return [
      _buildGradeSetting(t),
      const SizedBox(height: 8),
      _buildSubjectSetting(t),
      const SizedBox(height: 8),
      _buildTypesSetting(t),
      const SizedBox(height: 8),
      _buildDifficultySetting(t),
      const SizedBox(height: 8),
      _buildPromptSetting(t),
    ];
  }

  Widget _buildGradeSetting(Translations t) {
    return StatefulBuilder(
      builder: (context, set) => SettingItem(
        label: t.generate.presentationGenerate.grade,
        child: FlexDropdownField<GradeLevel>(
          value: grade,
          items: GradeLevel.values,
          itemBuilder: (_, g) => Text(g.getLocalizedName(t)),
          onChanged: (g) {
            onGradeChanged(g);
            set(() {});
          },
        ),
      ),
    );
  }

  Widget _buildSubjectSetting(Translations t) {
    return StatefulBuilder(
      builder: (context, set) => SettingItem(
        label: t.generate.presentationGenerate.subject,
        child: FlexDropdownField<Subject>(
          value: subject,
          items: Subject.values,
          itemBuilder: (_, s) => Text(s.getLocalizedName(t)),
          onChanged: (s) {
            onSubjectChanged(s);
            set(() {});
          },
        ),
      ),
    );
  }

  Widget _buildTypesSetting(Translations t) {
    return StatefulBuilder(
      builder: (context, set) => SettingItem(
        label: t.questionBank.filters.type,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: QuestionType.values.map((type) {
            final isSelected = selectedTypes.contains(type);
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                final next = Set<QuestionType>.from(selectedTypes);
                if (selected) {
                  next.add(type);
                } else if (next.length > 1) {
                  next.remove(type);
                }
                onTypesChanged(next);
                set(() {});
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDifficultySetting(Translations t) {
    return StatefulBuilder(
      builder: (context, set) {
        final theme = Theme.of(context);
        return SettingItem(
          label: t.common.difficulty,
          child: Column(
            children: Difficulty.values
                .map(
                  (d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Difficulty.getDifficultyColor(d),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(d.displayName)),
                        IconButton.outlined(
                          onPressed: difficultyCounts[d]! > 0
                              ? () {
                                  final next = Map<Difficulty, int>.from(
                                    difficultyCounts,
                                  );
                                  next[d] = next[d]! - 1;
                                  onDifficultyChanged(next);
                                  set(() {});
                                }
                              : null,
                          icon: const Icon(LucideIcons.minus, size: 16),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(34, 34),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${difficultyCounts[d]}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: difficultyCounts[d]! > 0
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: () {
                            final next = Map<Difficulty, int>.from(
                              difficultyCounts,
                            );
                            next[d] = next[d]! + 1;
                            onDifficultyChanged(next);
                            set(() {});
                          },
                          icon: const Icon(LucideIcons.plus, size: 16),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(34, 34),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildPromptSetting(Translations t) {
    return SettingItem(
      label: t.questionBank.advancedSettings.title,
      child: TextField(
        controller: promptController,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: t.questionBank.advancedSettings.explanation,
          hintText: t.questionBank.advancedSettings.explanationHint,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          isDense: true,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
