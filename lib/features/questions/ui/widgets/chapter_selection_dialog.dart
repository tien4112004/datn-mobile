import 'package:AIPrimary/features/questions/states/chapter_provider.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/enum_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Dialog for selecting a chapter based on grade and subject
class ChapterSelectionDialog extends ConsumerStatefulWidget {
  final GradeLevel? grade;
  final Subject? subject;
  final String? currentChapterId;

  const ChapterSelectionDialog({
    super.key,
    required this.grade,
    required this.subject,
    this.currentChapterId,
  });

  @override
  ConsumerState<ChapterSelectionDialog> createState() =>
      _ChapterSelectionDialogState();

  /// Show the chapter selection dialog
  static Future<String?> show(
    BuildContext context, {
    required GradeLevel? grade,
    required Subject? subject,
    String? currentChapterId,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => ChapterSelectionDialog(
        grade: grade,
        subject: subject,
        currentChapterId: currentChapterId,
      ),
    );
  }
}

class _ChapterSelectionDialogState
    extends ConsumerState<ChapterSelectionDialog> {
  String? _selectedChapterName;

  @override
  void initState() {
    super.initState();
    _selectedChapterName =
        widget.currentChapterId; // Actually stores chapter name
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    // Check if grade and subject are selected
    if (widget.grade == null || widget.subject == null) {
      return AlertDialog(
        icon: Icon(LucideIcons.info, color: colorScheme.primary, size: 48),
        title: Text(t.questionBank.selectGradeSubjectFirst.title),
        content: Text(t.questionBank.selectGradeSubjectFirst.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.questionBank.actions.ok),
          ),
        ],
      );
    }

    // Fetch chapters based on grade and subject
    final chaptersAsync = ref.watch(
      chaptersProvider((grade: widget.grade, subject: widget.subject)),
    );

    return AlertDialog(
      title: Text(
        t.questionBank.chapter.select,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: chaptersAsync.when(
          data: (chapters) {
            if (chapters.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.bookOpen,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.questionBank.noChaptersAvailable.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.questionBank.chapter.noChaptersFound(
                        grade: widget.grade?.localizedName(t) ?? '',
                        subject: widget.subject?.localizedName(t) ?? '',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              itemCount: chapters.length + 1, // +1 for "No chapter" option
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                // First item: "No chapter" option
                if (index == 0) {
                  final isSelected = _selectedChapterName == null;
                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                    title: Text(
                      t.questionBank.chapter.noChapter,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isSelected ? colorScheme.primary : null,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    subtitle: Text(t.questionBank.chapter.noChapterDescription),
                    onTap: () {
                      setState(() {
                        _selectedChapterName = null;
                      });
                    },
                  );
                }

                // Chapter items
                final chapter = chapters[index - 1];
                final isSelected = _selectedChapterName == chapter.name;

                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? colorScheme.primary : null,
                  ),
                  title: Text(
                    chapter.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected ? colorScheme.primary : null,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedChapterName = chapter.name;
                    });
                  },
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.circleAlert,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  t.questionBank.chapter.failedToLoadTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.questionBank.chapter.failedToLoad,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.questionBank.actions.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedChapterName);
          },
          child: Text(t.questionBank.actions.select),
        ),
      ],
    );
  }
}
