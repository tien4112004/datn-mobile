import 'package:flutter/material.dart';

class QuestionAdvancedOptions extends StatelessWidget {
  final String? chapter;
  final String explanation;
  final ValueChanged<String> onExplanationChanged;
  final VoidCallback? onChapterButtonPressed;

  const QuestionAdvancedOptions({
    super.key,
    this.chapter,
    required this.explanation,
    required this.onExplanationChanged,
    this.onChapterButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          'Advanced Settings',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        iconColor: colorScheme.onSurfaceVariant,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chapter Selection
                InkWell(
                  onTap: onChapterButtonPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bookmark_outline,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chapter',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                chapter != null && chapter!.isNotEmpty
                                    ? chapter!
                                    : 'Select Chapter (Optional)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: chapter != null && chapter!.isNotEmpty
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Explanation
                TextFormField(
                  initialValue: explanation,
                  onChanged: onExplanationChanged,
                  decoration: InputDecoration(
                    labelText: 'Explanation (Optional)',
                    hintText: 'Explain the answer...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
