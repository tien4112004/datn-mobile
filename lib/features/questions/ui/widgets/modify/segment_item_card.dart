import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';

/// Card widget for displaying and editing a fill-in-blank segment
class SegmentItemCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                                ? 'Blank ${index + 1}'
                                : 'Text ${index + 1}',
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
                    tooltip: 'Remove segment',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Content field
            if (isBlank) ...[
              TextFormField(
                initialValue: content,
                decoration: InputDecoration(
                  labelText: 'Placeholder Text *',
                  hintText: 'e.g., "answer" or "blank"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  helperText: 'This text will be shown in the blank space',
                ),
                onChanged: onContentChanged,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Placeholder text is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Acceptable answers field
              TextFormField(
                initialValue: acceptableAnswers?.join(', ') ?? '',
                decoration: InputDecoration(
                  labelText: 'Acceptable Answers *',
                  hintText: 'answer1, answer2, answer3',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  helperText: 'Separate multiple answers with commas',
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
                    return 'At least one acceptable answer is required';
                  }
                  return null;
                },
              ),
            ] else ...[
              TextFormField(
                initialValue: content,
                decoration: InputDecoration(
                  labelText: 'Text Content *',
                  hintText: 'Enter the text that appears in the question',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 3,
                onChanged: onContentChanged,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Text content is required';
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
