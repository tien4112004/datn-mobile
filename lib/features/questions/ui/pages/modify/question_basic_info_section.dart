import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/shared/widget/flex_dropdown_field.dart';

/// Section containing basic information fields for a question
class QuestionBasicInfoSection extends StatelessWidget {
  final TextEditingController titleController;
  final QuestionType selectedType;
  final Difficulty selectedDifficulty;
  final TextEditingController pointsController;
  final TextEditingController titleImageUrlController;
  final TextEditingController explanationController;
  final ValueChanged<QuestionType> onTypeChanged;
  final ValueChanged<Difficulty> onDifficultyChanged;

  const QuestionBasicInfoSection({
    super.key,
    required this.titleController,
    required this.selectedType,
    required this.selectedDifficulty,
    required this.pointsController,
    required this.titleImageUrlController,
    required this.explanationController,
    required this.onTypeChanged,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(
          context,
          'Basic Information',
          'Define the core properties of your question',
        ),
        const SizedBox(height: 16),

        // Title field (required)
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Question Title *',
            hintText: 'Enter your question here',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            helperText: 'This is the main question students will see',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Question title is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Question type and difficulty dropdowns
        Row(
          children: [
            // Question type dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question Type *',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlexDropdownField<QuestionType>(
                    value: selectedType,
                    items: QuestionType.values,
                    onChanged: onTypeChanged,
                    itemLabelBuilder: (type) => type.displayName,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Difficulty dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Difficulty *',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlexDropdownField<Difficulty>(
                    value: selectedDifficulty,
                    items: Difficulty.values,
                    onChanged: onDifficultyChanged,
                    itemLabelBuilder: (diff) => diff.displayName,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Points field (optional)
        TextFormField(
          controller: pointsController,
          decoration: InputDecoration(
            labelText: 'Points (Optional)',
            hintText: '0',
            prefixIcon: const Icon(Icons.star_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            helperText: 'Leave empty or 0 for ungraded questions',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final points = int.tryParse(value);
              if (points == null || points < 0) {
                return 'Please enter a valid number';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Title image URL (optional)
        TextFormField(
          controller: titleImageUrlController,
          decoration: InputDecoration(
            labelText: 'Title Image URL (Optional)',
            hintText: 'https://example.com/image.jpg',
            prefixIcon: const Icon(Icons.image_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            helperText: 'Add an image to accompany your question',
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasScheme) {
                return 'Please enter a valid URL';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Explanation field (optional)
        TextFormField(
          controller: explanationController,
          decoration: InputDecoration(
            labelText: 'Explanation (Optional)',
            hintText: 'Explain why this is the correct answer...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            helperText: 'This will be shown after students answer',
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: colorScheme.outlineVariant),
      ],
    );
  }
}
