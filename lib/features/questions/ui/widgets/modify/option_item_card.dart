import 'package:flutter/material.dart';

/// Card widget for displaying and editing a multiple choice option
class OptionItemCard extends StatelessWidget {
  final int index;
  final String text;
  final String? imageUrl;
  final bool isCorrect;
  final VoidCallback onRemove;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String?> onImageUrlChanged;
  final ValueChanged<bool> onCorrectChanged;
  final bool canRemove;

  const OptionItemCard({
    super.key,
    required this.index,
    required this.text,
    this.imageUrl,
    required this.isCorrect,
    required this.onRemove,
    required this.onTextChanged,
    required this.onImageUrlChanged,
    required this.onCorrectChanged,
    this.canRemove = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant,
          width: isCorrect ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with option label and remove button
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
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Option ${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCorrect) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                if (canRemove)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    iconSize: 20,
                    onPressed: onRemove,
                    tooltip: 'Remove option',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Option text field
            TextFormField(
              initialValue: text,
              decoration: InputDecoration(
                labelText: 'Option Text *',
                hintText: 'Enter option text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 2,
              onChanged: onTextChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Option text is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Image URL field (optional)
            TextFormField(
              initialValue: imageUrl,
              decoration: InputDecoration(
                labelText: 'Image URL (Optional)',
                hintText: 'https://example.com/image.jpg',
                prefixIcon: const Icon(Icons.image_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: onImageUrlChanged,
            ),
            const SizedBox(height: 12),

            // Correct answer checkbox
            CheckboxListTile(
              value: isCorrect,
              onChanged: (value) => onCorrectChanged(value ?? false),
              title: Text(
                'Correct Answer',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Mark this option as the correct answer',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}
