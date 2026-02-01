import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// Open Ended Question in Viewing Mode (Read-only)
/// Enhanced with Material 3 design principles
class OpenEndedViewing extends ConsumerWidget {
  final OpenEndedQuestion question;

  /// When false, hides the header (title, badges) to avoid duplication
  final bool showHeader;

  const OpenEndedViewing({
    super.key,
    required this.question,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return QuestionCardWrapper(
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      difficulty: question.difficulty,
      type: question.type,
      showHeader: showHeader,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  t.questionBank.viewing.viewingMode,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Question format info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.questionBank.viewing.questionFormat,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  t.questionBank.viewing.responseType,
                  t.questionBank.viewing.longFormTextAnswer,
                  Icons.text_snippet_outlined,
                  theme,
                ),
                if (question.data.maxLength != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    t.questionBank.viewing.characterLimit,
                    t.questionBank.viewing.characters(
                      count: question.data.maxLength!,
                    ),
                    Icons.text_fields,
                    theme,
                  ),
                ],
                const SizedBox(height: 8),
                _buildInfoRow(
                  t.questionBank.viewing.grading,
                  t.questionBank.viewing.manualGradingRequired,
                  Icons.grading_outlined,
                  theme,
                ),
              ],
            ),
          ),

          // Expected answer (if available)
          if (question.data.expectedAnswer != null) ...[
            const SizedBox(height: 16),
            Text(
              t.questionBank.viewing.expectedAnswerReference,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.questionBank.viewing.referenceAnswer,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.data.expectedAnswer!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
