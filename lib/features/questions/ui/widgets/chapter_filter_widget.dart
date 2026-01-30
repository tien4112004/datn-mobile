import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/states/chapter_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A stateful widget for chapter filtering that maintains local state
/// until the user confirms their selection
class ChapterFilterWidget extends ConsumerStatefulWidget {
  final GradeLevel? currentGrade;
  final Subject? currentSubject;
  final List<String> initialSelectedChapters;
  final ValueChanged<List<String>> onChaptersChanged;

  const ChapterFilterWidget({
    super.key,
    required this.currentGrade,
    required this.currentSubject,
    required this.initialSelectedChapters,
    required this.onChaptersChanged,
  });

  @override
  ConsumerState<ChapterFilterWidget> createState() =>
      _ChapterFilterWidgetState();
}

class _ChapterFilterWidgetState extends ConsumerState<ChapterFilterWidget> {
  late List<String> _localSelectedChapters;

  @override
  void initState() {
    super.initState();
    _localSelectedChapters = List.from(widget.initialSelectedChapters);
  }

  @override
  void didUpdateWidget(ChapterFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if initial selection changed from outside
    if (oldWidget.initialSelectedChapters != widget.initialSelectedChapters) {
      _localSelectedChapters = List.from(widget.initialSelectedChapters);
    }
  }

  void _toggleChapter(String chapter) {
    setState(() {
      if (_localSelectedChapters.contains(chapter)) {
        _localSelectedChapters.remove(chapter);
      } else {
        _localSelectedChapters.add(chapter);
      }
    });
    // Immediately notify parent of changes
    widget.onChaptersChanged(_localSelectedChapters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canShowChapter =
        widget.currentGrade != null && widget.currentSubject != null;

    if (!canShowChapter) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chapter Filter',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
                    'Please select both Grade and Subject to filter by Chapter',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Fetch chapters based on grade and subject
    final chaptersAsync = ref.watch(
      chaptersProvider((
        grade: widget.currentGrade,
        subject: widget.currentSubject,
      )),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Chapter',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select one or more chapters for ${widget.currentGrade?.displayName} - ${widget.currentSubject?.displayName}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        chaptersAsync.when(
          data: (chapters) {
            if (chapters.isEmpty) {
              return Container(
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
                        'No chapters available for the selected grade and subject',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chapters.map((chapter) {
                final isSelected = _localSelectedChapters.contains(chapter.id);
                return FilterChip(
                  label: Text(chapter.name),
                  selected: isSelected,
                  showCheckmark: true,
                  onSelected: (selected) => _toggleChapter(chapter.id),
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.onPrimaryContainer,
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: 1,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.circleAlert,
                  size: 20,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load chapters. Please try again.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
