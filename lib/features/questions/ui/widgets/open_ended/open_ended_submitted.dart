import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';

/// Open Ended Question in Submitted Mode
/// Shows submitted text read-only with neutral styling.
/// No score feedback, no expected answer, no explanation.
class OpenEndedSubmitted extends StatelessWidget {
  final OpenEndedQuestion question;
  final String? studentAnswer;
  final bool showHeader;

  const OpenEndedSubmitted({
    super.key,
    required this.question,
    this.studentAnswer,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasAnswer = studentAnswer?.isNotEmpty == true;

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
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Submitted',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Your answer section
          Text(
            'Your Answer',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasAnswer
                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasAnswer
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Text(
              hasAnswer ? studentAnswer! : 'No answer submitted',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: hasAnswer
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontStyle: hasAnswer ? FontStyle.normal : FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
          if (hasAnswer && question.data.maxLength != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${studentAnswer!.length}/${question.data.maxLength} characters',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
