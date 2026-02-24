import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/features/questions/data/dto/chapter_response_dto.dart';
import 'package:AIPrimary/features/questions/states/chapter_provider.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/widgets/flex_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Widget option builders for [QuestionGeneratePage]'s [GenerationSettingsSheet].
class QuestionWidgetOptions {
  final GradeLevel grade;
  final Subject subject;
  final Set<QuestionType> selectedTypes;
  final Map<Difficulty, int> difficultyCounts;
  final TextEditingController promptController;
  final String? selectedChapter;
  final void Function(GradeLevel) onGradeChanged;
  final void Function(Subject) onSubjectChanged;
  final void Function(Set<QuestionType>) onTypesChanged;
  final void Function(Map<Difficulty, int>) onDifficultyChanged;
  final void Function(String?) onChapterChanged;

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
    required this.onChapterChanged,
    this.selectedChapter,
  });

  List<Widget> buildAllSettings(Translations t) {
    return [
      // Grade, subject, and chapter share one StatefulBuilder so that changing
      // grade/subject triggers a rebuild of the Consumer inside, causing it to
      // re-watch chaptersProvider with the updated args (loading state fires).
      _buildGradeSubjectChapter(t),
      const SizedBox(height: 8),
      _buildTypesSetting(t),
      const SizedBox(height: 8),
      _buildDifficultySetting(t),
      const SizedBox(height: 8),
      _buildPromptSetting(t),
    ];
  }

  Widget _buildGradeSubjectChapter(Translations t) {
    final localGrade = [grade];
    final localSubject = [subject];
    final localChapter = [selectedChapter];

    return StatefulBuilder(
      builder: (context, set) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grade
            SettingItem(
              label: t.generate.presentationGenerate.grade,
              child: FlexDropdownField<GradeLevel>(
                value: localGrade[0],
                items: GradeLevel.values,
                itemBuilder: (_, g) => Text(g.getLocalizedName(t)),
                onChanged: (g) {
                  localGrade[0] = g;
                  localChapter[0] = null;
                  onGradeChanged(g);
                  onChapterChanged(null);
                  set(() {});
                },
              ),
            ),
            const SizedBox(height: 16),

            // Subject
            SettingItem(
              label: t.generate.presentationGenerate.subject,
              child: FlexDropdownField<Subject>(
                value: localSubject[0],
                items: Subject.values,
                itemBuilder: (_, s) => Text(s.getLocalizedName(t)),
                onChanged: (s) {
                  localSubject[0] = s;
                  localChapter[0] = null;
                  onSubjectChanged(s);
                  onChapterChanged(null);
                  set(() {});
                },
              ),
            ),
            const SizedBox(height: 16),

            // Chapter — Consumer is inside StatefulBuilder so it rebuilds
            // (and re-watches the correct provider) whenever grade/subject change.
            Consumer(
              builder: (context, ref, _) {
                final chaptersAsync = ref.watch(
                  chaptersProvider((
                    grade: localGrade[0],
                    subject: localSubject[0],
                  )),
                );

                return StatefulBuilder(
                  builder: (context, chapterSet) {
                    return SettingItem(
                      label: t.questionBank.chapter.title,
                      child: chaptersAsync.when(
                        loading: () => const SizedBox(
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (_, _) =>
                            Text(t.questionBank.chapter.failedToLoad),
                        data: (chapters) {
                          if (chapters.isEmpty) {
                            return Text(
                              t.questionBank.chapter.noAvailable,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            );
                          }

                          final items = <ChapterResponseDto?>[
                            null,
                            ...chapters,
                          ];
                          final currentValue = localChapter[0] == null
                              ? null
                              : chapters.cast<ChapterResponseDto?>().firstWhere(
                                  (c) => c?.name == localChapter[0],
                                  orElse: () => null,
                                );

                          return FlexDropdownField<ChapterResponseDto?>(
                            value: currentValue,
                            items: items,
                            itemBuilder: (_, c) => Text(
                              c?.name ?? t.questionBank.chapter.noChapter,
                            ),
                            onChanged: (c) {
                              localChapter[0] = c?.name;
                              onChapterChanged(c?.name);
                              chapterSet(() {});
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
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
    // ADVANCED_APPLICATION is excluded from question generation.
    final difficulties = Difficulty.values
        .where((d) => d != Difficulty.advancedApplication)
        .toList();

    return StatefulBuilder(
      builder: (context, set) {
        final theme = Theme.of(context);
        return SettingItem(
          label: t.common.difficulty,
          child: Column(
            children: difficulties
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
