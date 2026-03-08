import 'package:AIPrimary/features/questions/data/dto/chapter_response_dto.dart';
import 'package:AIPrimary/features/questions/states/chapter_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EducationModeOptions extends ConsumerWidget {
  final bool isEducationMode;
  final GradeLevel? gradeLevel;
  final Subject? subjectEnum;
  final String? chapter;
  final void Function() onToggle;
  final void Function(GradeLevel) onGradeChanged;
  final void Function(Subject) onSubjectChanged;
  final void Function(String) onChapterChanged;
  final Translations t;

  const EducationModeOptions({
    super.key,
    required this.isEducationMode,
    required this.gradeLevel,
    required this.subjectEnum,
    required this.chapter,
    required this.onToggle,
    required this.onGradeChanged,
    required this.onSubjectChanged,
    required this.onChapterChanged,
    required this.t,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle row
        Row(
          children: [
            Icon(
              LucideIcons.graduationCap,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              t.generate.educationMode.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Switch(value: isEducationMode, onChanged: (_) => onToggle()),
          ],
        ),
        // Education pickers (visible when mode is on)
        if (isEducationMode) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Subject picker
              OptionChip(
                icon: LucideIcons.bookOpen,
                label:
                    subjectEnum?.getLocalizedName(t) ??
                    t.generate.educationMode.selectSubject,
                onTap: () => _showSubjectPicker(context),
              ),
              // Grade picker
              OptionChip(
                icon: LucideIcons.layers,
                label:
                    gradeLevel?.getLocalizedName(t) ??
                    t.generate.educationMode.selectGrade,
                onTap: () => _showGradePicker(context),
              ),
              // Chapter picker
              _ChapterChip(
                gradeLevel: gradeLevel,
                subjectEnum: subjectEnum,
                chapter: chapter,
                onChapterChanged: onChapterChanged,
                t: t,
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showSubjectPicker(BuildContext context) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.educationMode.selectSubject,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: Subject.values.map((subject) {
          final isSelected = subjectEnum == subject;
          return ListTile(
            title: Text(subject.getLocalizedName(t)),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              onSubjectChanged(subject);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showGradePicker(BuildContext context) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.educationMode.selectGrade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: GradeLevel.values.map((grade) {
          final isSelected = gradeLevel == grade;
          return ListTile(
            title: Text(grade.getLocalizedName(t)),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              onGradeChanged(grade);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ChapterChip extends ConsumerWidget {
  final GradeLevel? gradeLevel;
  final Subject? subjectEnum;
  final String? chapter;
  final void Function(String) onChapterChanged;
  final Translations t;

  const _ChapterChip({
    required this.gradeLevel,
    required this.subjectEnum,
    required this.chapter,
    required this.onChapterChanged,
    required this.t,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canFetch = gradeLevel != null && subjectEnum != null;

    return OptionChip(
      icon: LucideIcons.bookMarked,
      label: chapter ?? t.generate.educationMode.selectChapter,
      onTap: canFetch ? () => _showChapterPicker(context, ref) : null,
    );
  }

  void _showChapterPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => _ChapterPickerSheet(
        gradeLevel: gradeLevel!,
        subjectEnum: subjectEnum!,
        selectedChapter: chapter,
        onChapterSelected: onChapterChanged,
        t: t,
      ),
    );
  }
}

class _ChapterPickerSheet extends ConsumerWidget {
  final GradeLevel gradeLevel;
  final Subject subjectEnum;
  final String? selectedChapter;
  final void Function(String) onChapterSelected;
  final Translations t;

  const _ChapterPickerSheet({
    required this.gradeLevel,
    required this.subjectEnum,
    required this.selectedChapter,
    required this.onChapterSelected,
    required this.t,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(
      chaptersProvider((grade: gradeLevel, subject: subjectEnum)),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      maxChildSize: 1,
      snap: true,
      snapSizes: const [0.5, 0.9],
      expand: true,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverList.list(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            t.generate.educationMode.selectChapter,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          chaptersAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (error, stackTrace) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  t.generate.educationMode.noChaptersAvailable,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            data: (chapters) =>
                                _buildChapterList(context, chapters, isDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChapterList(
    BuildContext context,
    List<ChapterResponseDto> chapters,
    bool isDark,
  ) {
    if (chapters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            t.generate.educationMode.noChaptersAvailable,
            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: chapters.map((chapter) {
        final isSelected = selectedChapter == chapter.name;
        return ListTile(
          title: Text(chapter.name),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          onTap: () {
            onChapterSelected(chapter.name);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }
}
