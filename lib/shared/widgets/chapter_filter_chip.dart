import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/questions/states/chapter_provider.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// A filter chip that loads chapters dynamically based on the selected
/// grade and subject. Single-select, reuses the same chaptersProvider
/// as the question bank.
class ChapterFilterChip extends ConsumerWidget {
  final GradeLevel? grade;
  final Subject? subject;
  final String? selectedChapter;
  final ValueChanged<String?> onChanged;

  const ChapterFilterChip({
    super.key,
    required this.grade,
    required this.subject,
    required this.selectedChapter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedChapter != null;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        _showChapterPicker(context, ref);
      },
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
              LucideIcons.bookMarked,
              size: 14,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              isSelected
                  ? selectedChapter!
                  : t.projects.common_list.filter_chapter,
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

  void _showChapterPicker(BuildContext context, WidgetRef ref) {
    final t = ref.read(translationsPod);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ChapterPickerSheet(
        grade: grade,
        subject: subject,
        selectedChapter: selectedChapter,
        label: t.projects.common_list.filter_chapter,
        onChanged: (chapter) {
          Navigator.pop(context);
          onChanged(chapter);
        },
      ),
    );
  }
}

class _ChapterPickerSheet extends ConsumerWidget {
  final GradeLevel? grade;
  final Subject? subject;
  final String? selectedChapter;
  final String label;
  final ValueChanged<String?> onChanged;

  const _ChapterPickerSheet({
    required this.grade,
    required this.subject,
    required this.selectedChapter,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (grade == null || subject == null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.info,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.questionBank.chapter.selectGradeAndSubject,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: _ChapterList(
                    grade: grade!,
                    subject: subject!,
                    selectedChapter: selectedChapter,
                    scrollController: scrollController,
                    onChanged: onChanged,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ChapterList extends ConsumerWidget {
  final GradeLevel grade;
  final Subject subject;
  final String? selectedChapter;
  final ScrollController scrollController;
  final ValueChanged<String?> onChanged;

  const _ChapterList({
    required this.grade,
    required this.subject,
    required this.selectedChapter,
    required this.scrollController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final chaptersAsync = ref.watch(
      chaptersProvider((grade: grade, subject: subject)),
    );

    return chaptersAsync.when(
      data: (chapters) {
        if (chapters.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                t.questionBank.chapter.noAvailable,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return ListView(
          controller: scrollController,
          children: [
            // "All" option to clear selection
            ListTile(
              leading: const Icon(LucideIcons.list),
              title: Text(t.common.all),
              selected: selectedChapter == null,
              onTap: () => onChanged(null),
            ),
            ...chapters.map(
              (chapter) => ListTile(
                title: Text(chapter.name),
                selected: selectedChapter == chapter.name,
                selectedColor: colorScheme.primary,
                onTap: () => onChanged(chapter.name),
                trailing: selectedChapter == chapter.name
                    ? Icon(
                        LucideIcons.check,
                        size: 16,
                        color: colorScheme.primary,
                      )
                    : null,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t.questionBank.chapter.failedToLoad,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
