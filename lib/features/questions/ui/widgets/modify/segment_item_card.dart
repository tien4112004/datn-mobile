import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Card widget for displaying and editing a fill-in-blank segment
class SegmentItemCard extends ConsumerWidget {
  final int index;
  final SegmentType type;
  final String content;
  final List<String>? acceptableAnswers;
  final VoidCallback onRemove;
  final ValueChanged<String> onContentChanged;
  final ValueChanged<List<String>>? onAcceptableAnswersChanged;
  final bool canRemove;

  const SegmentItemCard({
    super.key,
    required this.index,
    required this.type,
    required this.content,
    this.acceptableAnswers,
    required this.onRemove,
    required this.onContentChanged,
    this.onAcceptableAnswersChanged,
    this.canRemove = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);
    final isBlank = type == SegmentType.blank;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBlank
              ? colorScheme.secondary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant,
          width: isBlank ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isBlank
                            ? colorScheme.secondaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isBlank
                                ? Icons.edit_outlined
                                : Icons.text_fields_outlined,
                            size: 14,
                            color: isBlank
                                ? colorScheme.onSecondaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isBlank
                                ? '${t.questionBank.fillInBlank.addBlank} ${index + 1}'
                                : '${t.questionBank.fillInBlank.addText} ${index + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isBlank
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (canRemove)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    iconSize: 20,
                    onPressed: onRemove,
                    tooltip: t.common.delete,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Content field
            if (isBlank) ...[
              TextFormField(
                initialValue: content,
                decoration: InputDecoration(
                  labelText: t.questionBank.fillInBlank.placeholderText,
                  hintText: t.questionBank.fillInBlank.segmentHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  helperText: t
                      .questionBank
                      .fillInBlank
                      .blankHint, // Reusing or adding specific
                ),
                onChanged: onContentChanged,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.questionBank.fillInBlank.addBlankWarning;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Acceptable answers field
              TextFormField(
                initialValue: acceptableAnswers?.join(', ') ?? '',
                decoration: InputDecoration(
                  labelText: t.questionBank.fillInBlank.acceptableAnswers,
                  hintText: t.questionBank.fillInBlank.acceptableAnswersHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  helperText: t.questionBank.fillInBlank.exampleHint,
                ),
                maxLines: 2,
                onChanged: (value) {
                  final answers = value
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  onAcceptableAnswersChanged?.call(answers);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.questionBank.fillInBlank.acceptableAnswers;
                  }
                  return null;
                },
              ),
            ] else ...[
              TextFormField(
                initialValue: content,
                decoration: InputDecoration(
                  labelText: t.questionBank.fillInBlank.textContent,
                  hintText: t.questionBank.fillInBlank.textContentHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 3,
                onChanged: onContentChanged,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.questionBank.fillInBlank.textContent;
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
