import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// Section for managing open-ended question settings
class OpenEndedSection extends ConsumerWidget {
  final String? expectedAnswer;
  final int? maxLength;
  final ValueChanged<String> onExpectedAnswerChanged;
  final ValueChanged<int?> onMaxLengthChanged;

  const OpenEndedSection({
    super.key,
    this.expectedAnswer,
    this.maxLength,
    required this.onExpectedAnswerChanged,
    required this.onMaxLengthChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(
          context,
          t.questionBank.openEnded.title,
          t.questionBank.openEnded.subtitle,
        ),
        const SizedBox(height: 16),

        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.questionBank.openEnded.infoText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Expected answer field
        TextFormField(
          initialValue: expectedAnswer ?? '',
          onChanged: onExpectedAnswerChanged,
          decoration: InputDecoration(
            labelText: t.questionBank.openEnded.expectedAnswer,
            hintText: t.questionBank.openEnded.expectedAnswerHint,
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            helperText: t.questionBank.openEnded.expectedAnswerHelper,
            helperMaxLines: 2,
          ),
          maxLines: 5,
        ),
        const SizedBox(height: 16),

        // Max length field
        TextFormField(
          initialValue: maxLength?.toString() ?? '',
          onChanged: (value) {
            if (value.isEmpty) {
              onMaxLengthChanged(null);
            } else {
              final parsed = int.tryParse(value);
              if (parsed != null) {
                onMaxLengthChanged(parsed);
              }
            }
          },
          decoration: InputDecoration(
            labelText: t.questionBank.openEnded.maxLength,
            hintText: '0',
            prefixIcon: const Icon(Icons.format_size),
            suffixText: t.questionBank.openEnded.characters,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            helperText: t.questionBank.openEnded.maxLengthHelper,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final length = int.tryParse(value);
              if (length == null || length < 0) {
                return t.questionBank.openEnded.invalidNumber;
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Grading note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.edit_note_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.questionBank.openEnded.gradingNote,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.questionBank.openEnded.gradingNoteText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
